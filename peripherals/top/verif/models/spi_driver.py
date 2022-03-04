from random import randrange
import typing as T
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer
from cocotb.decorators import RunningTask
from cocotb.utils import get_sim_steps

from .spi_transactions import SPITransaction


class SPIDriver:
    def __init__(self) -> None:
        self.csn : ModifiableObject = None
        self.mosi: ModifiableObject = None
        self.miso: ModifiableObject = None
        self.sclk: ModifiableObject = None

        self._clk_driver : Clock = None
        self._clk_process : RunningTask = None

        self.pol = 0
        self.pha = 0

        self.msbfirst = 1

        self.transactions : T.List[SPITransaction] = list()
        self.transactions_done : T.List[SPITransaction] = list()
        
    def drive_clock(self, clk_period = (1,"us")) :
        if self._clk_process is not None :
            self.stop_clock()
        if self._clk_driver is not None :
            if get_sim_steps(self._clk_driver.period) != get_sim_steps(clk_period) :
                self._clk_driver = Clock(self.sclk,*clk_period)
        else :
            self._clk_driver = Clock(self.sclk,*clk_period)
        self.sclk._log.info("[SPI] Start Clock")
        self._clk_process = cocotb.fork(self._clk_driver.start(None,self.pol != 0))
    

    def stop_clock(self):
        if self._clk_process is not None :
            self._clk_process.kill()
            self._clk_process = None
        self.sclk.value = self.pol
    

    async def process_next_transaction(self) :
        assert self.valid
        self.stop_clock()
        self.csn.value = 1
        await Timer(randrange(1010,10100),"ns")
        self.csn.value = 0

        await Timer(1.5,'us')
        sampling_edge = self.active_clock_edge()
        sending_edge = self.inactive_clock_edge()
        transaction = self.transactions.pop(0)
        for word in transaction :
            miso_val = 0
            for bit in self.bin_word(word,16) :
                if not self.clock_driven :
                    self.drive_clock()
                else :
                    await sending_edge(self.sclk)
                self.mosi.value = bit
                await sampling_edge(self.sclk)
                miso_val <<= 1
                miso_val |= self.miso.value
            transaction.append_result(miso_val)
        self.transactions_done.append(transaction)

        self.stop_clock()
        await Timer(randrange(1010,10100),"ns")
        self.csn.value = 1
        

    def active_clock_edge(self) :
        falling = self.pol != 0
        falling = falling != (self.pha != 0)
        if falling:
            return FallingEdge
        else :
            return RisingEdge

    def inactive_clock_edge(self) :
        return RisingEdge if self.active_clock_edge == FallingEdge else FallingEdge

    def bin_word(self, data, size):
        word = f"{data:0{size}b}"
        output = [int(x) for x in word]
        if not self.msbfirst :
            output = reversed(output)
        return output
        
        

    @property
    def clock_driven(self) -> bool :
        return self._clk_process is not None

    @property
    def valid(self) -> bool :
        for elt in [self.csn, self.mosi, self.miso, self.sclk] :
            if elt is None: 
                return False
        return True

