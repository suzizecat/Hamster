import pyuvm
import vipy
from pyuvm import *

from .uvm_spi_items import *

class SPIReadMultiSeq(uvm_sequence):
    def __init__(self, name="uvm_sequence"):
        super().__init__(name)
        self.start_address = 0
        self.end_address = 0xFF

    async def body(self):
        command = SPIReadCommandItem("read_cmd",self.start_address)
        await self.start_item(command)
        await self.finish_item(command)
        nop = SPINoOpItem("nop")
        for _ in range(self.start_address,self.end_address) :
            await self.start_item(nop)
            await self.finish_item(nop)

        end = SPIEndOfFrameItem("eof")
        await self.start_item(end)
        await self.finish_item(end)

