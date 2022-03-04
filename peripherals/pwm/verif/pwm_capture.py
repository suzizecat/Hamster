import random
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer

from generic_controller import GenericController

class PwmCaptureController(GenericController) :
	def __init__(self,dut : HierarchyObject) -> None:
		self.dut = dut

		self.i_clk : ModifiableObject = dut.i_clk
		self.i_rst_n : ModifiableObject = dut.i_rst_n
		self.i_timebase : ModifiableObject = dut.i_timebase
		self.i_pwm : ModifiableObject = dut.i_pwm
		self.i_polarity : ModifiableObject = dut.i_polarity
		self.o_capture_start : ModifiableObject = dut.o_capture_start
		self.o_capture_done : ModifiableObject = dut.o_capture_done
		self.o_capture_value : ModifiableObject = dut.o_capture_value

		super().__init__(clk_handle=self.i_clk, rst_handle=self.i_rst_n)

	def reset_inputs(self):
		super().reset_inputs()
		self.i_timebase.value = 0
		self.i_pwm.value = 0
		self.i_polarity.value = 0
		self.o_capture_start.value = 0
		self.o_capture_done.value = 0
		self.o_capture_value.value = 0

	async def perform_sequence(self,timebase_prescaler,pwm_time,pwm_period,unit_t = "ns",pwm_pol = True) :
		async def timebase_gen() :
			await RisingEdge(self.i_clk)
			while True :
				self.i_timebase.value = 1
				await ClockCycles(self.i_clk,1)
				self.i_timebase.value = 0
				await ClockCycles(self.i_clk,timebase_prescaler-1)
				
		cocotb.log.info("[SEQ] Start sequence")
		tgen = await cocotb.start(timebase_gen())
		self.i_pwm.value = pwm_pol
		await Timer(pwm_time,unit_t)
		self.i_pwm.value = not pwm_pol
		await Timer(pwm_period - pwm_time,unit_t)
		tgen.kill()
		cocotb.log.info("[SEQ] End of sequence")


