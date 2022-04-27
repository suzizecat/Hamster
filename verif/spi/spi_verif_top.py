import pyuvm
from pyuvm import *

from uvm.spi_testsuite import BaseTest

from vipy.bus.base.serial import SerialMode
from vipy.bus.spi import SPIBase

from cocotb import top

@pyuvm.test()
class MyTest(BaseTest):
    def start_of_simulation_phase(self):
        super().start_of_simulation_phase()
        ConfigDB().set(None,"*","spi_master",True)
        ConfigDB().set(None,"*","spi_interface",SPIBase.SPIInterface(
            mosi=top.i_mosi,
            miso=top.o_miso,
            csn=top.i_cs_n,
            clk=top.i_spi_clk
        ))
        ConfigDB().set(None,"*","spi_mode",0)