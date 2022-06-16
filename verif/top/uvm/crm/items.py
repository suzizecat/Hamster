from random import *
from pyuvm import *
import vipy

import typing as T

class ClkItem(uvm_sequence_item):
    def __init__(self, name, period : T.Tuple[int,str]):
        super().__init__(name)
        self.data = period

    def __str__(self) -> str:
        if self.is_stop :
            return "CLK STOP"
        return f"CLK New period {self.data}"

    @property
    def is_stop(self):
        return self.data[0] == 0


