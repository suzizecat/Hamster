from vipy.structure import *
from vipy.drivers import *
from vipy.bus.spi import *
from .spi_reg import HamsterSPIInterface


class Hamster(Component):
    def __init__(self,dut):
        super().__init__()
        self.dut = dut
        self.name = "top"

        self.reset = ResetDriver(dut.i_rst_n)
        self.clock = ClockDriver(dut.i_clk,period=(10,"ns"))
        self.spi = HamsterSPIInterface(SPIInterface(
            mosi=dut.i_mosi,
            miso=dut.o_miso,
            clk=dut.i_spi_clk,
            csn=dut.i_cs_n
        ))

    async def init(self) :
        await self.reset_drivers()
        await self.clock.start()