import random
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer

from cocoverif.bus.base import *
from cocoverif.bus.spi import *


def full_reset(dut):
    dut.i_clk.value = 0     
    dut.i_rst_n.value = 0   
    dut.i_enc1_a.value = 0  
    dut.i_enc1_b.value = 0  
    dut.i_enc1_i.value = 0  
    dut.i_enc2_a.value = 0  
    dut.i_enc2_b.value = 0  
    dut.i_enc2_i.value = 0  
    dut.i_channels.value = 0
    dut.o_cmd_m1.value = 0  
    dut.o_cmd_m2.value = 0  
    dut.i_cs_n.value = 1    
    dut.i_mosi.value = 0    
    dut.i_spi_clk.value = 0 
    dut.o_miso.value = 0    


async def pwm_gen(signal : ModifiableObject, period, length):
    while True:
        signal.value = 0xF
        await Timer(length,"ns")
        signal.value = 0
        await Timer(period - length,"ns")

async def enc_drive(a,b, length) :
    while True:
        a.value = 0
        b.value = 0
        await Timer(length,"ns")
        a.value = 1
        b.value = 0
        await Timer(length,"ns")
        a.value = 1
        b.value = 1
        await Timer(length,"ns")
        a.value = 0
        b.value = 1
        await Timer(length,"ns")


async def print_items(queue):
    while True:
        item = await queue.get()
        cocotb.log.info(f"Got item : {str(item)} - 0x{item.value:04X}")

@cocotb.test()
async def test_spi(dut : HierarchyObject):
    clk = Clock(dut.i_clk,100,"ns")

    full_reset(dut)
    await Timer(280,"ns")
    cocotb.fork(clk.start())
    await Timer(330,"ns")
    dut.i_rst_n.value = 1
    await RisingEdge(dut.i_clk)

    spi_itf = SPIBase.SPIInterface(
        mosi=dut.i_mosi,
        miso=dut.o_miso,
        clk=dut.i_spi_clk,
        csn=dut.i_cs_n
        )
    DataWord.word_size = 16
    
    drv = SPIDriver(SerialMode.MASTER,spi_itf)
    mon = SPIMonitor(SerialMode.MASTER,spi_itf)
    await mon.start()
    disp = cocotb.fork(print_items(mon.to_handle))

    sending = DataWord(0x01A9)
    sending2 = DataWord(0x0000)
    drv.to_send.put_nowait(sending)
    drv.to_send.put_nowait(sending2)
    drv.csn_pulse_per_word = False
    drv.start()
    await drv.to_send.is_empty.wait()
    cocotb.log.info(f"Send queue is now empty")
    await drv.evt.word_done.wait()
    cocotb.log.info(f"Last word is completed")
    drv.stop()
    disp.kill()
    await Timer(5,"us")
