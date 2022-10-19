from dataclasses import dataclass
from random import randrange
from cocotb import *
from cocotb.handle import ModifiableObject
from cocotb.triggers import *
from vipy.structure import *
from vipy.drivers import *

class PrescalerFinderDriver(GenericDriver):
    @dataclass
    class Interface:
        i_clk : ModifiableObject
        i_rst_n : ModifiableObject
        i_reference_event : ModifiableObject
        i_start : ModifiableObject
        i_period_target : ModifiableObject
        o_prescaler : ModifiableObject
        o_done : ModifiableObject
        o_ongoing : ModifiableObject

    def __init__(self, dut, period_ref = 1,unit_ref = "step"):
        super().__init__()

        self.itf = PrescalerFinderDriver.Interface(
            i_clk = dut.i_clk,
            i_rst_n = dut.i_rst_n,
            i_reference_event = dut.i_reference_event,
            i_start = dut.i_start,
            i_period_target = dut.i_period_target,
            o_prescaler = dut.o_prescaler,
            o_done = dut.o_done,
            o_ongoing = dut.o_ongoing
        )

        self.clk = ClockDriver(self.itf.i_clk,period=(10,"ns"))
        self.rst = ResetDriver(self.itf.i_rst_n)
        self.start = SignalDriver(self.itf.i_start)
        self.ref = SignalDriver(self.itf.i_reference_event)

        self.period_ref = get_sim_steps(period_ref,unit_ref)
        self.bitsize = dut.K_PERIODWIDTH.value.integer
        self.prescaler_width = dut.K_PRESCWIDTH.value.integer
        self.register_remaining_signals_as_driven("*_i")

        self._trigger_handler : Task = None

    @drive_method
    async def reset(self):
        self.itf.i_period_target.value = 0
        await self.reset_drivers()
        await self.clk.start()

    @property
    def max_value(self) :
        return (2**self.bitsize)-1

    @drive_method
    async def set_target(self, val) :
        if self.itf.o_ongoing.value :
            self._log.warning(f"Changing value while operation is ongoing.")
        self.itf.i_period_target.value = val

    @drive_method
    async def run(self,target) :
        await self.set_target(target)
        await self._process()

    async def _process(self) :
        self._log.lmed(f"Starting calibration process")
        await RisingEdge(self.itf.i_clk)
        await cocotb.start(self.start.pulse(1,self.clk.period+1))
        await Timer(randrange(1,self.period_ref//2))
        n_event = 0
        while self.itf.o_ongoing.value :
            await RisingEdge(self.itf.i_clk)
            self._log.lmed(f"Done bit {n_event:2d}/{self.prescaler_width}")
            n_event += 1
            await cocotb.start(self.ref.pulse(1,self.clk.period+1))
            await Timer(self.period_ref)

        self._log.lmed(f"Calibration should be done")
