from random import randrange
from re import I
import typing as T
import cocotb
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer, Edge, First
from cocotb.decorators import RunningTask
from cocotb.utils import get_sim_steps
from cocotb.queue import Queue
from .spi_transactions import SPITransaction

class SPIMonitor:
    def __init__(self) -> None:
        self.csn : ModifiableObject = None
        self.mosi: ModifiableObject = None
        self.miso: ModifiableObject = None
        self.sclk: ModifiableObject = None

        self.pol = 0
        self.pha = 0

        self.msbfirst = 1
        self.pkt_size= 16

        self._raw_data_mosi : Queue[int] = Queue()
        self._raw_data_miso : Queue[int] = Queue()
        
        self._checkers = list()

    @property
    def active_clock_edge(self) :
        falling = self.pol != 0
        falling = falling != (self.pha != 0)
        if falling:
            return FallingEdge
        else :
            return RisingEdge

    @property
    def inactive_clock_edge(self) :
        return RisingEdge if self.active_clock_edge == FallingEdge else FallingEdge
        
    
    async def clock_pol_checker(self) :
        csn_falling_edge = FallingEdge(self.csn)
        csn_rising_edge = RisingEdge(self.csn)
        clk_edge = Edge(self.sclk)

        if self.csn.value != 1 :
            self.sclk._log.info(f"[SPI MON] Waiting for high level for CSN")
            await csn_rising_edge

        self.sclk._log.info(f"[SPI MON] Start clock polarity checker")

        while True :
            assert self.sclk.value == self.pol, f"SPI Clock should be aligned with polarity while CSN high"
            if (await First(csn_falling_edge,clk_edge)) is csn_falling_edge :
                await csn_rising_edge

    async def clock_pha_checker(self) :
        active_edge = self.active_clock_edge(self.sclk)
        mosi_data_edge = Edge(self.mosi)
        miso_data_edge = Edge(self.miso)
        csn_falling_edge = FallingEdge(self.csn)
        csn_rising_edge = RisingEdge(self.csn)

        if self.csn.value != 1 :
            self.sclk._log.info(f"[SPI MON] Waiting for high level for CSN")
            await csn_rising_edge

        self.sclk._log.info(f"[SPI MON] Start clock phase checker")
        while True :
            await csn_falling_edge
            while self.csn.value == 1 : 
                evt = await First(active_edge,mosi_data_edge,miso_data_edge)
                if evt != active_edge :
                    evt = await First(Timer(1),active_edge)
                    assert evt == active_edge, f"[SPI MON] Data changed without active clock edge"

    async def data_catcher(self) :
        capture_edge = self.inactive_clock_edge(self.sclk)
        csn_falling_edge = FallingEdge(self.csn)
        csn_rising_edge = RisingEdge(self.csn)

        if self.csn.value != 1 :
            self.sclk._log.info(f"[SPI MON] Waiting for high level for CSN")
            await csn_rising_edge

        self.sclk._log.info(f"[SPI MON] Start recording data")
        cnt = 0
        data_miso = ""
        data_mosi = ""
        while True:
            await csn_falling_edge
            while self.csn.value == 0 :
                evt = await First(csn_rising_edge, capture_edge)
                if evt == capture_edge :
                    data_miso += self.miso.value.binstr
                    data_mosi += self.mosi.value.binstr
                    cnt += 1

                    if cnt == self.pkt_size :
                        if not self.msbfirst :
                            data_miso = reversed(data_miso)
                            data_mosi = reversed(data_mosi)
                        self.mosi._log.debug(f"[SPI MON] Captured MOSI = 0b{data_mosi} MISO = 0b{data_miso}")
                        self._raw_data_miso.put_nowait(BinaryValue(value=data_miso))
                        self._raw_data_mosi.put_nowait(BinaryValue(value=data_mosi))
                        cnt = 0
                        data_miso = ""
                        data_mosi = ""
                else :
                    if cnt != 0 :
                        self.csn._log.info(f"[SPI MON] Dropping incomplete data due to CSN rise with cnt = {cnt}")
            
    def start_checkers(self) :
        for chk in [self.clock_pha_checker, self.clock_pol_checker, self.data_catcher] :
            self._checkers.append(cocotb.start_soon(chk()))
    
    def stop_checkers(self):
        for chk in self._checkers :
            chk.kill()
                

            



        


            
            
