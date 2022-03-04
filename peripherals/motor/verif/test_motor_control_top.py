import random
import cocotb
from cocotb import clock
from cocotb.clock import Clock
from cocotb.decorators import RunningTask
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, NextTimeStep, RisingEdge, Timer

from model.motor_controller import MotorControllerDriver

@cocotb.test()
async def base(dut : ModifiableObject) :
    ctrl = MotorControllerDriver(dut)
    await ctrl.reset_sequence()

    ctrl.io.i_param_pwm_max.value = 100
    ctrl.io.i_pwm_command.value = 100
    ctrl.abi._step_interval = (1,"us")
    ctrl.abi.start()

    await ClockCycles(ctrl.io.i_clk,500)
