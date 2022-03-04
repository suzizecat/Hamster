import random
import cocotb
from cocotb.clock import Clock
from cocotb.handle import HierarchyObject, ModifiableObject
from cocotb.triggers import ClockCycles, FallingEdge, Join, RisingEdge, Timer

from models import SPIDriver
from models import SPITransaction
from models import SPIHeader

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

#@cocotb.test()
async def test_bringup(dut : HierarchyObject) :
    
    clk = Clock(dut.i_clk,100,"ns")

    full_reset(dut)
    await Timer(280,"ns")
    cocotb.fork(clk.start())
    await Timer(330,"ns")
    dut.i_rst_n.value = 1
    await RisingEdge(dut.i_clk)
    cocotb.fork(pwm_gen(dut.i_channels,1024*100,600*100))
    cocotb.fork(enc_drive(dut.i_enc1_a,dut.i_enc1_b,300))
    cocotb.fork(enc_drive(dut.i_enc2_a,dut.i_enc2_b,300))
    # cocotb.fork(pwm_gen(dut.channel[1],10e3,5e3))
    # cocotb.fork(pwm_gen(dut.channel[2],10e3,5e3))
    # cocotb.fork(pwm_gen(dut.channel[0],10e3,5e3))
    await Timer(1,"ms")


@cocotb.test()
async def test_spi(dut : HierarchyObject):
    clk = Clock(dut.i_clk,100,"ns")

    full_reset(dut)
    await Timer(280,"ns")
    cocotb.fork(clk.start())
    await Timer(330,"ns")
    dut.i_rst_n.value = 1
    await RisingEdge(dut.i_clk)

    spi = SPIDriver()
    spi.miso = dut.o_miso
    spi.mosi = dut.i_mosi
    spi.csn  = dut.i_cs_n
    spi.sclk = dut.i_spi_clk

    tr_read_test = SPITransaction(SPIHeader(address=0x5A),length=1)

    spi.transactions.append(tr_read_test)
  
    dut.i_mosi._log.info(f"SPI Command {str(spi.transactions[0].header)}")
    dut.i_mosi._log.info(f"Sending SPI {str(spi.transactions[0])}")
    await spi.process_next_transaction()
    dut.o_miso._log.info(f"Result is   {spi.transactions_done[-1].str_result}")


    await Timer(1,"us")

@cocotb.test()
async def test_spi_read_all(dut : HierarchyObject):
    clk = Clock(dut.i_clk,100,"ns")

    full_reset(dut)
    await Timer(280,"ns")
    cocotb.fork(clk.start())
    await Timer(330,"ns")
    dut.i_rst_n.value = 1
    await RisingEdge(dut.i_clk)

    spi = SPIDriver()
    spi.miso = dut.o_miso
    spi.mosi = dut.i_mosi
    spi.csn  = dut.i_cs_n
    spi.sclk = dut.i_spi_clk

    tr_read_test = SPITransaction(SPIHeader(address=0x00),length=0x5B)

    spi.transactions.append(tr_read_test)
    while len(spi.transactions) :
        dut.i_mosi._log.info(f"SPI Command {str(spi.transactions[0].header)}")
        dut.i_mosi._log.info(f"Sending SPI {str(spi.transactions[0])}")
        await spi.process_next_transaction()
        dut.o_miso._log.info(f"Result is   {spi.transactions_done[-1].str_result}")


    await Timer(1,"us")

