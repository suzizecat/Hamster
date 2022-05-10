from random import randint
import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock

async def reset(clk,rst):
    rst.value = 0
    clk.value = 0

    await Timer(10,"us")
    clk_hdl = Clock(clk,10,"ns")
    rst.value = 1
    return cocotb.fork(clk_hdl.start())



@cocotb.test()
async def base_test(dut):
    n_substep = dut.K_NSUBSTEPS.value.integer
    dut.i_step_trigger.value = 0
    dut.i_step_polarity_rev.value = 0
    dut.i_step_reverse.value = 0
    dut.i_brake.value = 0
    dut.i_power.value = 0
    dut.o_pattern.value = 0

    clk_task = await reset( dut.i_clk,dut.i_rst_n)
    
    await RisingEdge(dut.i_clk)
    for j in range(10) :
        pow_value = randint(0,n_substep-1)
        dut.i_power._log.info(f"Setting {pow_value:=}")
        dut.i_power.value = pow_value
        for i in range(6*n_substep) :
            dut.i_step_trigger.value = 1
            await ClockCycles(dut.i_clk,1)
            dut.i_step_trigger.value = 0
            await ClockCycles(dut.i_clk,5)

        dut.i_power.value = 0
        await Timer(1,"us")
    clk_task.kill()







