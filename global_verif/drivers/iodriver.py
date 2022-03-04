import typing as T
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ReadWrite, Timer
from cocotb.triggers import FallingEdge, RisingEdge
from cocotb import Coroutine
from cocotb.handle import ModifiableObject

class IODriver:
	def __init__(self) -> None:
		self._registered_signals : T.Dict[str,ModifiableObject] = None
		self._registered_inputs  : T.Dict[str,ModifiableObject] = None
		self._registered_outputs : T.Dict[str,ModifiableObject] = None

	def _var_is_input(self,var) :
		if isinstance(var,ModifiableObject) and var._name.startswith(("i_","io_")) :
			cocotb.log.debug(f"[IO] Registering input  {var._name}")
			return True
		return False

	def _var_is_output(self,var) :
		if isinstance(var,ModifiableObject) and var._name.startswith(("o_","io_")) :
			cocotb.log.debug(f"[IO] Registering output {var._name}")
			return True
		return False

	def _var_reset_value(self,elt : ModifiableObject) :
		return 0

	def _register_ios(self) :
		elt : ModifiableObject
		for elt in vars(self).values() :
			if isinstance(elt,ModifiableObject) :
				self._register_signal(elt)
			

	def _register_signal(self,signal : ModifiableObject) :
		if not isinstance(signal,ModifiableObject) :
			raise TypeError(f"Expected cocotb's ModifiableObject, got {type(signal)}")
		
		if self._registered_signals is None :
			self._registered_signals = dict()
		if self._registered_inputs is None :
			self._registered_inputs = dict()
		if self._registered_outputs is None :
			self._registered_outputs = dict()

		if self._var_is_input(signal) :
			self._registered_signals[signal._name] = signal
			self._registered_inputs[signal._name] = signal

		if self._var_is_output(signal) :
			self._registered_signals[signal._name] = signal
			self._registered_outputs[signal._name] = signal

	@property
	def inputs(self):
		if self._registered_inputs is None :
			self._register_ios()
		return self._registered_inputs
		
	@property
	def outputs(self):
		if self._registered_outputs is None :
			self._register_ios()
		return self.outputs

	def reset_all_inputs(self):
		for signal in self.inputs.values() :
			signal.value = self._var_reset_value(signal)