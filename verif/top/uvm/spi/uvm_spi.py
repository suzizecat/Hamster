import typing as T

import pyuvm
from pyuvm import *
from random import *
from cocotb.triggers import *
import vipy

from .uvm_spi_items import *

class SPIDriver(uvm_driver):
    def build_phase(self):
        super().build_phase()
    
    def start_of_simulation_phase(self):
        super().start_of_simulation_phase()
        spi_mode = vipy.bus.base.SerialMode.MASTER
        itf : vipy.bus.spi.SPIInterface = ConfigDB().get(self,"","interface")
        clk_period = ConfigDB().get(self,"","clkperiod")
        self.bridge = vipy.bus.spi.SPIDriver(spi_mode,itf,clk_period)
        self.bridge.csn_pulse_per_word = False

    async def run_phase(self):
        await self.bridge.reset()
        self.bridge.start()
        while True:
            item : T.Any[SPIControlItemBase,SPIDataItemBase] = await self.seq_item_port.get_next_item()
            cocotb.log.info(item)
            if isinstance(item,SPIDataItemBase) :
                cocotb.log.info(f"Sending data {item.data}")
                self.bridge.to_send.put_nowait(item.data)
            elif isinstance(item,SPIControlItemBase):
                if isinstance(item,SPIEndOfFrameItem) :
                    
                    await self.bridge.to_send.is_empty.wait()
                    await self.bridge.evt.word_done.wait()
                elif isinstance(item,SPIWaitItem) :
                    await Timer(*item.delay)
            self.seq_item_port.item_done()

class SPIMonitor(uvm_monitor):    
    def start_of_simulation_phase(self):
        super().start_of_simulation_phase()
        itf : vipy.bus.spi.SPIInterface = ConfigDB().get(self,"","interface")
        spi_mode = ConfigDB().get(self,"","spi_mode")
        self.bridge = vipy.bus.spi.SPIMonitor(spi_mode,itf)

    async def run_phase(self):
        self.bridge.start()
        while True:
            data : vipy.bus.base.DataWord = await self.bridge.to_handle.get()
            self.logger.info(f"Captured data {data}")


class SPIAgent(uvm_agent):
    def build_phase(self):
        super().build_phase()
        itf : vipy.bus.spi.SPIInterface = ConfigDB().get(self,"","interface")
        clk_period = ConfigDB().get(self,"","clkperiod")

        self.monitor_slave  = SPIMonitor("mon_slave",self)
        self.monitor_master = SPIMonitor("mon_master",self)

        ConfigDB().set(self,"mon_slave","interface",itf)
        ConfigDB().set(self,"mon_master","interface",itf)
        ConfigDB().set(self,"mon_slave","spi_mode",vipy.bus.base.SerialMode.SLAVE)
        ConfigDB().set(self,"mon_master","spi_mode",vipy.bus.base.SerialMode.MASTER)

        if self.active :
            self.driver_master = SPIDriver("drv_master",self)
            ConfigDB().set(self,"drv_master","interface",itf)
            ConfigDB().set(self,"drv_master","clkperiod",clk_period)

            self.seqr = uvm_sequencer("seqr",self)
            ConfigDB().set(self,"","seqr",self.seqr)

    def connect_phase(self):
        super().connect_phase()

        if self.is_active :
            self.driver_master.seq_item_port.connect(self.seqr.seq_item_export)


