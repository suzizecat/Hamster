import pyuvm
from pyuvm import *

from .hamster_tb import HamsterTB
from .spi.uvm_sequences import *


class BaseTest(uvm_test):
    def build_phase(self):
        super().build_phase()
        self.tb = HamsterTB("tb",self)

    def end_of_elaboration_phase(self):
        self.seq = None

    async def run_phase(self):
        self.raise_objection()
        await self.seq.start()
        self.drop_objection()