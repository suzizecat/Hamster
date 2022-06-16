
from pyuvm import *
from uvm.spi.uvm_sequences import *
from uvm.crm.sequences import * 
from uvm.uvm_tests import *

import vipy
vipy.bus.base.DataWord.word_size = 16

class TopSeq(uvm_sequence):
    async def body(self):
        spi_seqr = ConfigDB().get(None,"uvm_test_top.tb.spi","seqr")
        crm_clk_seqr = ConfigDB().get(None,"uvm_test_top.tb.crm","clkseqr")
        start_clk = CRMStdSeq("boot")
        readall =  SPIReadMultiSeq("seq")
    
        readall.end_address = 0x03
        await start_clk.start(crm_clk_seqr)
        await readall.start(spi_seqr)

@pyuvm.test()
class ReadAllTest(BaseTest):
    def end_of_elaboration_phase(self):
        self.seq = TopSeq()

    async def run_phase(self):
        self.raise_objection()
        await self.seq.start()
        self.drop_objection()
