import pyuvm
from pyuvm import *

from .uvm_tb import HamsterTB
from .uvm_sequences import *

@pyuvm.test()
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