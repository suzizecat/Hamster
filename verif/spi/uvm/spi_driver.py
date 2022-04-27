from cocotb.triggers import Timer
import pyuvm
from pyuvm import *
from cocotb import top

import vipy
from vipy.bus.base import SerialMode

class SPI_Driver(uvm_driver):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.bridge : vipy.bus.spi.SPIDriver = None


    def start_of_simulation_phase(self):
        super().start_of_simulation_phase()
        self.bridge = vipy.bus.spi.SPIDriver(
            mode=SerialMode.MASTER if ConfigDB().get(self,"","spi_master") else SerialMode.SLAVE,
            itf=ConfigDB().get(self,"","spi_interface"),
            clk_period=ConfigDB().get(self,"","spi_period") if ConfigDB().exists(self,"","spi_period") else (1,"us")
        )

        self.bridge.spi_mode = ConfigDB().get(self,"","spi_mode")

    async def run_phase(self):
        self.raise_objection()
        self.logger.info("Start run phase")
        await self.bridge.reset()
        self.logger.info("Reset done")
        await self.bridge.drive_clock()
        self.logger.info("Drive clock done")
        await Timer(5,"us")
        self.drop_objection()

    def end_of_run_phase(self):
        print("Finito")
        

