import random
import cocotb
from cocotb import clock
from cocotb.clock import Clock
from cocotb.decorators import RunningTask
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, NextTimeStep, RisingEdge, Timer

from vipy.externals.encoders import EncoderABI

async def drive_timebase(clock,tbpin,period):
    tbpin.value = 0
    while True:
        await Timer(*period)
        await RisingEdge(clock)
        tbpin.value = 1
        await NextTimeStep()
        await RisingEdge(clock)
        tbpin.value = 0


@cocotb.test()
async def base(dut : ModifiableObject) :
    c = await cocotb.start(Clock(dut.i_clk,10,"ns").start())
    timebase = await cocotb.start(drive_timebase(dut.i_clk,dut.i_speed_time_base,(100,"us")))
    dut.i_rst_n.value = 1
    itf = EncoderABI.ABIInterface(a=dut.i_enc_a,b=dut.i_enc_b,i=dut.i_enc_i)
    encoder = EncoderABI(300,itf=itf)
    encoder.speed_tr_per_sec = 10000
    dut.i_param_pwr_on_pattern_msb.value = 0
    await encoder.start()
    cocotb.log.info(f"Low speed")
    for i in range(25):
        await Timer(10,"us")
    encoder.speed_tr_per_sec = 25000
    cocotb.log.info(f"High speed, pwr on LSB")
    for i in range(25):
        await Timer(10,"us")
    dut.i_param_pwr_on_pattern_msb.value = 1
    cocotb.log.info(f"High speed, pwr on MSB")
    for i in range(25):
        await Timer(10,"us")
    dut.i_reverse.value = 1
    cocotb.log.info(f"High speed, pwr on MSB, reverse")
    for i in range(30):
        await Timer(10,"us")
    encoder.direction = 0
    cocotb.log.info(f"High speed, pwr on MSB, reverse, direction inverted")
    for i in range(25):
        await Timer(10,"us")
    # ctrl = MotorControllerDriver(dut)
    # await ctrl.reset_sequence()

    # ctrl.io.i_param_pwm_max.value = 100
    # ctrl.io.i_pwm_command.value = 100
    # ctrl.abi._step_interval = (1,"us")
    # ctrl.abi.start()

    # await ClockCycles(ctrl.io.i_clk,500)
