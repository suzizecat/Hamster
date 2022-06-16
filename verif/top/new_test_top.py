import random
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer

from vipy.bus.base import *
from vipy.bus.spi import *

from vipy.externals.encoders import *

DataWord.word_size = 16

async def full_reset(dut):
    dut.i_rst_n.value = 1  
    await Timer(10,"ns")
    dut.i_rst_n.value = 0   
    dut.i_clk.value = 0     
    dut.i_enc1_a.value = 0  
    dut.i_enc1_b.value = 0  
    dut.i_enc1_i.value = 0  
    dut.i_enc2_a.value = 0  
    dut.i_enc2_b.value = 0  
    dut.i_enc2_i.value = 0  
    dut.i_channels.value = 0
    dut.i_cs_n.value = 1    
    dut.i_mosi.value = 0    
    dut.i_spi_clk.value = 0 

def spi_read(address):
    return DataWord(0x01 << 8 | (address & 0xFF))

def spi_write(address):
    return DataWord(0x02 << 8 | (address & 0xFF))

def spi_nop():
    return DataWord(0)

@cocotb.test()
async def read_spi(dut):
    await full_reset(dut)

    itf = EncoderABI.ABIInterface(a=dut.i_enc1_a,b=dut.i_enc1_b,i=dut.i_enc1_i)
    encoder = EncoderABI(300,itf=itf)
    encoder.speed_tr_per_sec = 100000
    await encoder.start()

    spi_itf = SPIBase.SPIInterface(
        mosi=dut.i_mosi,
        miso=dut.o_miso,
        clk=dut.i_spi_clk,
        csn=dut.i_cs_n
    )

    await Timer(100,"ns")
    dut.i_rst_n.value = 1
    clk = await cocotb.start(Clock(dut.i_clk,1,"ns").start())
    await Timer(100,"ns")
    spi_mode = 0
    spi_drv = SPIDriver(SerialMode.MASTER,spi_itf,(10,"ns"))
    spi_drv.csn_pulse_per_word = False
    spi_drv.spi_mode = spi_mode
    
    spi_mon_so = SPIMonitor(SerialMode.MASTER,spi_itf)
    spi_mon_mo = SPIMonitor(SerialMode.SLAVE,spi_itf)
    spi_mon_so.spi_mode = spi_mode
    spi_mon_mo.spi_mode = spi_mode
    spi_mon_mo.start()
    
    spi_mon_so.start()
    
    spi_drv.start()
    
    async def mon_master():
        while True :
            word : DataWord = await spi_mon_mo.to_handle.get()
            if word.value == 0 :
                cocotb.log.info(f"Sent nop word")
            else : 
                cocotb.log.info(f"Sent     word {word}")

    async def mon_slave():
        while True :
                cocotb.log.info(f"Recieved word {await spi_mon_so.to_handle.get()}")

    async def timer():
        for i in range(5):
            cocotb.log.info(i)
            await Timer(10,"us")

    tsk_master = cocotb.start_soon(mon_master())
    tsk_slave = cocotb.start_soon(mon_slave())
    sim_done = cocotb.start_soon(timer())

    await Timer(500,"ns")
    spi_drv.to_send.put_nowait(spi_write(0x0B))
    spi_drv.to_send.put_nowait(DataWord(1000))
    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    await Timer(1,"us")

    #spi_drv.to_send.put_nowait(DataWord(0x8001))
    spi_drv.to_send.put_nowait(spi_read(0xA9))
    spi_drv.to_send.put_nowait(spi_nop())
    
    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    await Timer(500,"ns")

    spi_drv.to_send.put_nowait(spi_read(0xA9))
    spi_drv.to_send.put_nowait(spi_nop())
    
    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    cocotb.log.info("Second wait")
    await Timer(500,"ns")
    cocotb.log.info("Sending next transaction")
    spi_drv.to_send.put_nowait(spi_read(0x00))
    spi_drv.to_send.put_nowait(spi_nop())
    spi_drv.to_send.put_nowait(spi_nop())
    spi_drv.to_send.put_nowait(spi_nop())

    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    
    
    await Timer(35,"us")
    spi_drv.to_send.put_nowait(spi_write(0x07))
    spi_drv.to_send.put_nowait(DataWord(1 << 6))
    #spi_drv.to_send.put_nowait(spi_nop())
    
    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    await Timer(1,"us")

    spi_drv.to_send.put_nowait(spi_read(0x07))
    spi_drv.to_send.put_nowait(spi_nop())
    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    await Join(sim_done)
    tsk_master.kill()
    tsk_slave.kill()
    clk.kill()





@cocotb.test()
async def radio(dut) : 
    await full_reset(dut)
    clk = await cocotb.start(Clock(dut.i_clk,1,"ns").start())
    await Timer(100,"ns")
    dut.i_rst_n.value = 1
    await Timer(1,"us")
    dut.i_channels.value = 0x1
    await ClockCycles(dut.i_clk,102+128 + 10)
    dut.i_channels.value = 0x0
    await Timer(1,"us")
    clk.kill()
