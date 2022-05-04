from secrets import randbits
import pyuvm
from pyuvm import *
from vipy.bus.base import DataWord

class SPI_Item(uvm_sequence_item):
    def __init__(self, name):
        super().__init__(name)
        self.data = DataWord(0)

    def randomize(self):
        self.data._from_int(randbits(self.data.wsize))
    
    def __str__(self) -> str:
        return f"Word {self.get_name()} : {self.data.value:0{self.data.wsize}b}"

    def __eq__(self, __o: "SPI_Item") -> bool:
        return self.value == __o.value and self.wsize == __o.wsize