import cocotb
from cocotb.triggers import *
from vipy.structure import *
from vmodules import PrescalerFinderDriver



@cocotb.test()
async def basic(dut):
    drv = GlobalEnv().get_top(PrescalerFinderDriver,dut,4119*444,"ns")
    await drv.reset()

    await drv.run(4119)
    drv._log.lhigh(f"Output result is : {drv.itf.o_prescaler.value.integer}")
    await Timer(1,"us")


