from re import I
import typing as T

import pyuvm
from pyuvm import *
from random import *
from cocotb.triggers import *
from cocotb.clock import *
import cocotb.handle
import vipy
from .items import *

class ClockDriver(uvm_driver):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self._drv_process = None

    def start_of_simulation_phase(self):
        super().start_of_simulation_phase()

        itf : cocotb.handle.ModifiableObject = ConfigDB().get(self,"","interface")
        clk_period = ConfigDB().get(self,"","clkperiod")
        self.bridge = Clock(itf,*clk_period)

    async def run_phase(self):
        self.bridge.signal.value = 0
        while True:
            item : ClkItem = await self.seq_item_port.get_next_item()
            if item.is_stop :
                if self._drv_process is not None :
                    self._drv_process.kill()
                    self._drv_process = None
                    self.bridge.signal.value = 0
            else :
                if self._drv_process is None or self.bridge.period != get_sim_steps(*(item.data)) :
                    if self._drv_process is not None :
                        self._drv_process.kill()
                    self.bridge = Clock(self.bridge.signal,*(item.data))
                    self._drv_process = await cocotb.start(self.bridge.start())
            
            self.seq_item_port.item_done()



class ResetDriver(uvm_driver):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self._drv_process = None

    def start_of_simulation_phase(self):
        super().start_of_simulation_phase()

        itf : cocotb.handle.ModifiableObject = ConfigDB().get(self,"","interface")
        clk_period = ConfigDB().get(self,"","clkperiod")
        self.bridge = Clock(itf,*clk_period)

    async def run_phase(self):
        self.bridge.signal.value = 0
        while True:
            item : ClkItem = await self.seq_item_port.get_next_item()
            if item.is_stop :
                if self._drv_process is not None :
                    self._drv_process.kill()
                    self._drv_process = None
                    self.bridge.signal.value = 0
            else :
                if self._drv_process is None or self.bridge.period != get_sim_steps(*(item.data)) :
                    if self._drv_process is not None :
                        self._drv_process.kill()
                    self.bridge = Clock(self.bridge.signal,*(item.data))
                    self._drv_process = await cocotb.start(self.bridge.start())
            
            self.seq_item_port.item_done()
    
class CRMAgent(uvm_agent):
    def build_phase(self):
        super().build_phase()

        if self.active :
            self.clkdrive = ClockDriver("clk",self)
            self.clkseqr = uvm_sequencer("clkseqr",self)
            ConfigDB().set(self,"","clkseqr",self.clkseqr)

    
    def connect_phase(self):
        super().connect_phase()

        if self.is_active :
            cocotb.log.info("Connection")
            self.clkdrive.seq_item_port.connect(self.clkseqr.seq_item_export)