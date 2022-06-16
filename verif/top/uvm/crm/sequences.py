import pyuvm
import vipy
from pyuvm import *
from cocotb.triggers import *

from .items import *

class CRMStdSeq(uvm_sequence):
    def __init__(self, name="uvm_sequence"):
        super().__init__(name)

    async def body(self):
        start_clk = ClkItem("boot_clk",(10,"ns"))
        await self.start_item(start_clk)
        await self.finish_item(start_clk)

        
        