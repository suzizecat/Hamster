from re import I
from click import launch
from cocotb.triggers import Timer
import pyuvm
from pyuvm import *
from cocotb import top
from cocotb.triggers import RisingEdge
from .spi_item import SPI_Item
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

    async def launch_tb(self):
        self.logger.info("Start test")
        await self.bridge.reset()
        await self.bridge.drive_clock()
        self.bridge.start()
        await RisingEdge(self.bridge.itf.clk)

    async def run_phase(self):
        await self.launch_tb()
        while True :
            item : SPI_Item = await self.seq_item_port.get_next_item()
            await self.bridge.to_send.put(item.data)
            await self.bridge.evt.word_done.wait()
            self.seq_item_port.item_done()

        

