import random
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer


@cocotb.test()
async def simple(dut) :
    dut.i_clk.value = 0
    dut.i_rst_n.value              = 0
    dut.i_force_step_value.value   = 0
    dut.i_force_step_trigger.value = 0
    dut.i_step_trigger.value       = 0
    dut.i_step_polarity.value      = 0
    dut.i_step_reverse.value       = 0
    dut.i_brake.value              = 0

    await Timer(50,"ns")
    dut.i_rst_n.value = 1
    cocotb.fork(Clock(dut.i_clk,10,"ns").start())

    await Timer(20,"ns")
    for i in range(12):
        dut.i_step_trigger.value = 1
        await ClockCycles(dut.i_clk,1)
        dut.i_step_trigger.value = 0
        dut.i_step_reverse.value = 0
        await ClockCycles(dut.i_clk,2)
        dut.i_step_reverse.value = 1
        await ClockCycles(dut.i_clk,1)




    
