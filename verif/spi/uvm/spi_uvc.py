import pyuvm
from pyuvm import *

from .spi_driver import SPI_Driver

from cocotb.clock import Clock
from cocotb import top
class SPI_UVC(uvm_env):
    def build_phase(self):
        super().build_phase()
        self.driver : SPI_Driver =  SPI_Driver.create("driver",self)
    
    async def run_phase(self):
        await cocotb.start(Clock(top.i_clk,10,"ns").start())
