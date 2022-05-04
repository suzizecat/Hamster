from secrets import randbits
import pyuvm
from pyuvm import *

from .spi_item import SPI_Item

class TestAllSeq(uvm_sequence):
    async def body(self):
        seqr = ConfigDB().get(None,"","sequencer")
        await RandomSeq("rand").start(seqr)


class RandomSeq(uvm_sequence):
    async def body(self):
        for i in range(100) :
            seq_itm = SPI_Item("seq_itm")
            await self.start_item(seq_itm)
            seq_itm.randomize()
            await self.finish_item(seq_itm)