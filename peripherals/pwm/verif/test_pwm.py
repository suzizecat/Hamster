import random
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer

from pwm_capture import PwmCaptureController

@cocotb.test()
async def simple_pwm(dut, prescaler = 10 ,p = 10000 ) :
    ctrl = PwmCaptureController(dut)
    ctrl.enable_clock_control()
    
    await ctrl.reset_sequence()
    
    for i in range(10) :
        t = random.randint(0,p-100)
        cocotb.log.info(f"Iteration {i} : PWM length is {t}")
        task = await cocotb.start(ctrl.perform_sequence(prescaler,t,p))
        await RisingEdge(ctrl.o_capture_done)
        actual_value = ctrl.o_capture_value.value.integer
        expected_value = ((t // 10) -1) // prescaler
        assert expected_value == actual_value, "Incorrect output value"
        await Join(task)
    await Timer(100,"ns")
    
