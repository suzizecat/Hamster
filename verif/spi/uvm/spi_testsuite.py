from re import I
import pyuvm
from pyuvm import *
from cocotb.triggers import Timer
from .spi_uvc import SPI_UVC
from .spi_sequences import TestAllSeq
from vipy.bus.base import DataWord

@pyuvm.test()
class BaseTest(uvm_test):
    def build_phase(self):
        super().build_phase()
        DataWord.word_size=16
        self.uvc = SPI_UVC("uvc", self)
    
    def end_of_elaboration_phase(self):
        self.test_seq = TestAllSeq.create("test_all")

    async def run_phase(self):
        self.raise_objection()
        await self.test_seq.start()
        self.drop_objection()
    
