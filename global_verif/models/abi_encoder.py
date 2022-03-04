import typing as T
import random
import cocotb
from cocotb.clock import Clock
from cocotb.decorators import RunningTask
from cocotb.triggers import ReadWrite, Timer
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb import Coroutine
from cocotb.handle import ModifiableObject

class ABIEncoderDriver:
    def __init__(self) -> None:
        self.a : ModifiableObject = None
        self.b : ModifiableObject = None
        self.i : ModifiableObject = None

        self.steps = 300
        self._step_interval : T.Tuple[int,str] = (1,"ms")
        self._current_step = 0
        self._direct_direction = 1
        self._run_process : RunningTask = None

    def start(self, iteration_limit : int = None) :
        async def run(self, iteration_limit : int = None):
            values = [(1,1),(1,0),(0,0),(0,1)]
            iteration_done = 0
            while iteration_limit is None or iteration_done < iteration_limit:
                (self.a.value,self.b.value) = values[self._current_step%4]
                self._current_step += 1 if self._direct_direction else -1
                if not 0 <= self._current_step < self.steps :
                    self._current_step = (self._current_step + self.steps ) % self.steps

                self.i.value = self._current_step == 0
                await Timer(*self._step_interval)
        
        if self._run_process is not None :
            self.stop()
        self._run_process = cocotb.fork(run(self,iteration_limit))
    
    def stop(self):
        if self._run_process is not None :
            self._run_process.kill()
            self._run_process = None

