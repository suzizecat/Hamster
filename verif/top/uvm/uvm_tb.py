import pyuvm
from pyuvm import *
import vipy.bus.spi as vipy_spi
from .uvm_spi import SPIAgent

from cocotb import top as hdl

class HamsterTB(uvm_env):
    def build_phase(self):
        super().build_phase()

        self.spi_interface = vipy_spi.SPIInterface(
            clk=hdl.i_spi_clk,
            mosi=hdl.i_mosi,
            miso=hdl.o_miso,
            csn=hdl.i_cs_n
        )
        self.spi_clk_period = (100,"ns")

        self.agt_spi = SPIAgent("spi",self)
        self.agt_spi.is_active = uvm_active_passive_enum.UVM_ACTIVE
        
        ConfigDB().set(self,"spi","interface",self.spi_interface)
        ConfigDB().set(self,"spi","clkperiod",self.spi_clk_period)
