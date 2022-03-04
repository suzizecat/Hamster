import typing as T
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer
from cocotb.decorators import RunningTask
from cocotb.utils import get_sim_steps

class SPIHeader:
    READ = 1
    WRITE = 2

    def __init__(self, command = READ, address = 0) -> None:
        self.command = command
        self.address = address
    
    @property
    def value(self) :
        return ((self.command & 0xFF ) << 8) | (self.address & 0xFF)
    
    
    def  __str__(self) -> str:
        out = ""
        if self.command == self.READ :
            out = "READ"
        if self.command == self.WRITE :
            out = "WRITE"
        
        out += f" to address 0x{self.address:02X}"
        return out

class SPITransaction:
    def __init__(self,header : SPIHeader, data = None,name = "", length = 1 ) -> None:
        self.name = name
        self.header = header
        self.data_content = list(data) if data is not None else list()
        self.return_data = list()
        
        if length > len(self.data_content) :
            self.data_content.extend([0]*(length - len(self.data_content)))

        self._iter_pos = 0

    def __iter__(self) :
        self._iter_pos = 0
        return self

    def __next__(self) :
        if self._iter_pos == 0 :
            self._iter_pos += 1
            return self.header.value
        elif self._iter_pos <= len(self.data_content) :
            val = self.data_content[self._iter_pos - 1]
            self._iter_pos += 1
            return val
        else :
            raise StopIteration
    
    def __str__(self) -> str:
        ret = "[" + ", ".join(["xxxx"] + [f"{x:04X}" for x in self.data_content]) + "]"
        return ret

    @property
    def str_result(self) :
        return "[" + ", ".join([f"{x:04X}" for x in self.return_data]) + "]"
        
    def append_result(self,data) :
        self.return_data.append(data)