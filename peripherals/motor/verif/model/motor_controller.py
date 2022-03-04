import random
import cocotb
from cocotb.clock import Clock
from cocotb.decorators import RunningTask
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, NextTimeStep, RisingEdge, Timer

from drivers import IODriver
from models import ABIEncoderDriver

class MotorControllerDriver :
    class _IO(IODriver) :
        def __init__(self,dut) -> None:
            super().__init__()
            self.i_clk                      : ModifiableObject = dut.i_clk                     
            self.i_rst_n                    : ModifiableObject = dut.i_rst_n                   
            self.i_enc_a                    : ModifiableObject = dut.i_enc_a                   
            self.i_enc_b                    : ModifiableObject = dut.i_enc_b                   
            self.i_enc_i                    : ModifiableObject = dut.i_enc_i                   
            self.i_brake                    : ModifiableObject = dut.i_brake                   
            self.i_reverse                  : ModifiableObject = dut.i_reverse                 
            self.i_pwm_command              : ModifiableObject = dut.i_pwm_command             
            self.i_param_enc_pol            : ModifiableObject = dut.i_param_enc_pol           
            self.i_param_i_step             : ModifiableObject = dut.i_param_i_step            
            self.i_param_i_step_en          : ModifiableObject = dut.i_param_i_step_en         
            self.i_param_pwm_max            : ModifiableObject = dut.i_param_pwm_max           
            self.i_param_pwr_on_pattern_msb : ModifiableObject = dut.i_param_pwr_on_pattern_msb
            self.i_param_pwr_on_pattern_all : ModifiableObject = dut.i_param_pwr_on_pattern_all

            self.o_cmd                      : ModifiableObject = dut.o_cmd

    def __init__(self,dut) -> None:
        self.io = MotorControllerDriver._IO(dut)
    
        self.clk   = Clock(self.io.i_clk,100,"ns")
        self.rst_n = self.io.i_rst_n

        self.abi = ABIEncoderDriver()
        self.abi.a = self.io.i_enc_a
        self.abi.b = self.io.i_enc_b
        self.abi.i = self.io.i_enc_i

        self._clk_process : RunningTask = None
    
    def stop_clk(self) :
        if self._clk_process is not None :
            self._clk_process.kill()
            self._clk_process = None

    def start_clk(self) :
        self.stop_clk()
        self._clk_process = cocotb.fork(self.clk.start())

    async def reset_sequence(self) :
        self.abi.stop()
        self.stop_clk()
        self.io.reset_all_inputs()

        await Timer(10*self.clk.period)

        self.io.i_rst_n.value = 1
        await Timer(1*self.clk.period)
        self.start_clk()
        await NextTimeStep()

