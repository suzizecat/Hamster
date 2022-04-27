import pyuvm
from pyuvm import *
from cocotb.triggers import Timer
from .spi_uvc import SPI_UVC

@pyuvm.test()
class BaseTest(uvm_test):
    def build_phase(self):
        super().build_phase()
        self.uvc = SPI_UVC("uvc", self)

    async def run_phase(self):
        self.raise_objection()
        await Timer(150,"us")
        self.drop_objection()
    
