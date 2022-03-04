import typing as T
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ReadWrite, Timer
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb import Coroutine
from cocotb.handle import ModifiableObject
from cocotb import RunningTask
from .iodriver import IODriver

class ClockDriver:
    def __init__(self, ioset : IODriver) -> None:
        self.signal : ModifiableObject = None
        self.period : T.Tuple[float,str] = (10,"ns")
        self._driver : Clock = None
        self._drv_process : RunningTask = None
