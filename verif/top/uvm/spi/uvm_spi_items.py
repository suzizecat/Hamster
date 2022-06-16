from random import *
from pyuvm import *
import vipy

import typing as T

class SPIControlItemBase(uvm_sequence_item):
    pass

class SPIDataItemBase(uvm_sequence_item):
    pass


class SPIDataItem(SPIDataItemBase):
    def __init__(self, name, data):
        super().__init__(name)
        if isinstance(data,vipy.bus.base.DataWord) :
            self.data = data
        else :
            self.data = vipy.bus.base.DataWord(data)

    def __str__(self) -> str:
        return f"SPI Data {self.data}"


class SPICommandItem(SPIDataItemBase):
    def __init__(self, name, command, arg):
        super().__init__(name)
        self.command = command
        self.arg = arg

    @property
    def word_value(self):
        return self.command & 0xFF << 8 | self.arg & 0xFF

    @property
    def data(self):
        return vipy.bus.base.DataWord(self.word_value)
    
    def __str__(self) -> str:
        return f"SPI Command {self.command:02X} - {self.arg:02X}"

class SPIReadCommandItem(SPICommandItem):
    def __init__(self, name, address):
        super().__init__(name,0x01,address)
        self.address = address
    
    def __str__(self) -> str:
        return f"SPI READ {self.arg:02X}"

class SPINoOpItem(SPICommandItem):
    def __init__(self, name):
        super().__init__(name,0x00,0x00)
    
    def __str__(self) -> str:
        return f"SPI No Operation"

class SPIEndOfFrameItem(SPIControlItemBase):
    def __str__(self) -> str:
        return f"SPI EOF"


class SPIWaitItem(SPIControlItemBase):
    def __init__(self, name,delay : T.Tuple[int,str] = None):
        super().__init__(name)
        self.delay = delay

        if self.delay is None :
            self.randomize

    def randomize(self):
        self.delay = T.Tuple(randrange(50,1000),"ns")

    def __str__(self) -> str:
        return f"SPI delay of {self.delay[0]} {self.delay[1]}"