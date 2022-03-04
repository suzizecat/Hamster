import typing as T
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ReadWrite, Timer
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb import Coroutine
from cocotb.handle import ModifiableObject

class GenericController:
    def __init__(self, clk_handle : ModifiableObject = None, rst_handle : ModifiableObject = None) -> None:

        self.clk : ModifiableObject = clk_handle
        self.rst : ModifiableObject = rst_handle

        self._control_clock = False
        self._clk_process : Coroutine = None
        self._clk_period : T.Tuple[int,str] = (10,"ns")
      
    def enable_clock_control(self,use_local_clk = True) :
        self._control_clock = True

    def start_clk(self, period : T.Tuple[int,str] = None) :
        if period is None :
            period = self._clk_period
        else :
            self._clk_period = period

        if self._clk_process is not None :
            self._clk_process.kill()
        if self._control_clock :
            self._clk_process = cocotb.fork(Clock(self.clk,*period).start())
    
    def stop_clk(self) :
        if self._clk_process is not None :
            self._clk_process.kill()

    def reset_inputs(self) :      
        self.rst.value = 0

    async def reset_sequence(self,reset_period : T.Tuple[int,str] = (50,"ns")) :
        self.stop_clk()
        self.reset_inputs()

        await Timer(*reset_period)
        self.rst.value = 1
        self.start_clk()
        await ReadWrite()

    

