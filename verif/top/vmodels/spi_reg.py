import cocotb
from cocotb.log import default_config as cocotb_log_config
from cocotb import Task
from cocotb.triggers import *

from vipy.bus.base import *
from vipy.bus.spi import *

from vipy.drivers import *
from vipy.structure import *

from vipy.regbank.reader import CSVReader
from vipy.regbank.structure import *


class WriteRequest:
    def __init__(self,target,value) -> None:
        self.target = target
        self.value = value
        self.reg_addr = None

    def __lt__(self,other : "WriteRequest"):
        return self.reg_addr < other.reg_addr
        

class HamsterSPIInterface(GenericDriver):
    def __init__(self, itf : SPIInterface) -> None:
        super().__init__()
        self.rb : RegisterBank = None
        self.itf: SPIInterface = itf

        self.pending_accesses : list[WriteRequest] = list()

        self.spi_mode = 0
        self.spi_drv = SPIDriver(SerialMode.MASTER,self.itf,(100,"ns"))
        self.spi_drv.csn_pulse_per_word = False
        self.spi_drv.spi_mode = self.spi_mode
        self.spi_mon_so : SPIMonitor = None
        self.spi_mon_mo : SPIMonitor = None

        self.mon_master : Task = None
        self.mon_slave : Task = None

        self.last_read_value  : DataWord = None
        self.got_word = Event()

        self._load_rb()
        self._setup_spi()

    async def reset(self):
        await self.reset_drivers()
        self.rb.reset()
    
    def end_of_build(self):
        self._load_rb()
        self._setup_spi()

    def _load_rb(self) :
        csv = CSVReader()
        csv.read_csv("../../rtl/regbank/definition/hamster_regbank.csv")
        self.rb = csv.current_rb
    
    def _setup_spi(self) :        
        self.spi_mon_so = SPIMonitor(SerialMode.MASTER,self.itf)
        self.spi_mon_mo = SPIMonitor(SerialMode.SLAVE,self.itf)
        self.spi_mon_so.spi_mode = self.spi_mode
        self.spi_mon_mo.spi_mode = self.spi_mode
        
        self.spi_mon_mo.start()
        self.spi_mon_so.start()

        self._start_monitoring()


    def _start_monitoring(self) :
        async def mon_master():
            while True :
                word : DataWord = await self.spi_mon_mo.to_handle.get()
                if word.value == 0 :
                    self._log.lmed(f"    Sent nop word")
                else : 
                    self._log.lmed(f"    Sent     word {word}")

        async def mon_slave():
            while True :
                self.last_read_value = await self.spi_mon_so.to_handle.get()
                self._log.lmed(f"    Recieved word {self.last_read_value}")
                self.got_word.set()

        self.mon_master = cocotb.start_soon(mon_master())
        self.mon_slave = cocotb.start_soon(mon_slave())

    def store_write(self,target : str,value : int) :
        self.pending_accesses.append(WriteRequest(target,value))

    def compress_write(self) :
        compressed_requests : dict[str,WriteRequest] = dict()
        for req in self.pending_accesses :
            register : Register = self.rb.get_register(req.target)
            if register.name in compressed_requests :
                curr_request = compressed_requests[register.name]
            else :
                curr_request = WriteRequest(register.name,None)
            curr_request.reg_addr = register.offset
            target = self.rb[req.target]
            if isinstance(target, Field) :
                if curr_request.value is None :
                    curr_request.value = register.value
                curr_request.value = target.apply_value_to(req.value,curr_request.value)
            elif isinstance(target, Register) :
                curr_request.value = req.value & register.mask
            else :
                self._log.error(f"Invalid request payload type :{type(target)!s}")
                continue
            
            compressed_requests[register.name] = curr_request

        self.pending_accesses = list(sorted(compressed_requests.values()))


    def store_sof_write(self,address) :
        self._log.lmed(f"Start WRITE frame at 0x{address:02X} ({self.rb[address].name if address in self.rb else 'Unbound'})")
        self.spi_drv.to_send.put_nowait(DataWord(0x02 << 8 | (address & 0xFF)))

    def store_sof_read(self,address) :

        self._log.lmed(f"Start READ  frame at 0x{address:02X} ({self.rb[address].name if address in self.rb else 'Unbound'})")
        self.spi_drv.to_send.put_nowait(DataWord(0x01 << 8 | (address & 0xFF)))

    def add_data_to_send(self,value) :
        val = value if isinstance(value,DataWord) else DataWord(value)
        self.spi_drv.to_send.put_nowait(val)

    async def send_write(self) :
        previous_reg : Register = None
        for req in self.pending_accesses :
            if isinstance(req.target,str) :
                current_reg = self.rb.get_register(req.target)
                rb_target = self.rb[req.target]
            elif isinstance(req.target,Register) :
                current_reg = req.target
                rb_target = current_reg
            else: 
                self._log.error(f"Invalid request payload type for exchange :{type(req.target)!s}")
                continue
            self.rb[rb_target.name].write_value(req.value)
            if previous_reg is None or previous_reg.offset != current_reg.offset -1 :
                await self.spi_drv.drive_csn(1,(1,"us"))
                await self.spi_idle()
                self._log.lhigh(f"Start write transaction to {current_reg.name}")
                if previous_reg is not None :
                    self._log.llow(f"Delta offset is {current_reg.offset} - 1 = {previous_reg.offset}")
                if isinstance(req,WriteRequest) :
                    self.store_sof_write(current_reg.offset)
            else :
                self._log.lmed(f"Continue write on {current_reg.name}")
            self.add_data_to_send(req.value)
            previous_reg = current_reg
        await self.spi_drv.drive_csn(1,(10,"ns"))
        await self.spi_drv.is_idle.wait()

    async def read(self, reg, assert_coherency = True) :
        self._log.lhigh(f"Read register {reg}")
        reg = self.rb.get_register(reg)
        if reg is None :
            self._log.warning(f"Tentative of unbound access through '{reg!r}'")
            return
        await self.spi_idle()
        await self.spi_drv.drive_csn(1,(1,"us"))
        self.store_sof_read(reg.offset)
        self.add_data_to_send(0)
        await self.spi_drv.evt.word_done.wait()
        await self.spi_idle()
        await Timer(*self.spi_drv.csn_pulse_duration)
        if self.rb[reg.name].value != int(self.last_read_value) :
            self._log.warning(f"Mismatch in register bank value for {reg.name}: expected 0x{self.rb[reg.name].value:04X} got 0x{int(self.last_read_value):04X}")
            assert not assert_coherency , f"Mismatch in register bank value on asserted READ" 
        return self.last_read_value



    async def spi_idle(self):
        await self.spi_drv.is_idle.wait()
        self._log.debug("     SPI IDLE detected.")
        await NextTimeStep()
