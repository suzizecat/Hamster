import pyuvm
from pyuvm import *

from .spi_driver import SPI_Driver
from .spi_sequences import TestAllSeq
from .spi_sequences import RandomSeq
from cocotb.clock import Clock
from cocotb import top


class SPI_UVC(uvm_env):
    def build_phase(self):
        super().build_phase()

        self.sequencer = uvm_sequencer("sequencer",self)
        ConfigDB().set(None,"","sequencer",self.sequencer)

        self.driver : SPI_Driver =  SPI_Driver.create("driver",self)

    def connect_phase(self):
        self.driver.seq_item_port.connect(self.sequencer.seq_item_export)
    
    async def run_phase(self):
        await cocotb.start(Clock(top.i_clk,10,"ns").start())
