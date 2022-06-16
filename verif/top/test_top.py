from pyuvm import *
from uvm.uvm_tests import *
from uvm.uvm_sequences import *


class TopSeq(uvm_sequence):
    async def body(self):
        spi_seqr = ConfigDB().get(None,"uvm_test_top.tb.spi","seqr")
        readall =  SPIReadMultiSeq("seq")
        await readall.start(spi_seqr)

@pyuvm.test()
class ReadAllTest(BaseTest):
    def end_of_elaboration_phase(self):
        
        self.seq = TopSeq()
