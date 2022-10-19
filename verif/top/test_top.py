import cocotb
from cocotb.clock import *
from cocotb.handle import *
from cocotb.triggers import *

from vipy.bus.base import *
from vipy.bus.spi import *

from vipy.externals.encoders import *

from vipy.structure import GlobalEnv

from vmodels import HamsterSPIInterface,Hamster

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
    cocotb.log.info(f"SPI Read  address {address:02X}")
    return DataWord(0x01 << 8 | (address & 0xFF))

def spi_write(address):
    cocotb.log.info(f"SPI Write address {address:02X}")
    return DataWord(0x02 << 8 | (address & 0xFF))

def spi_nop():
    return DataWord(0)


from vipy.structure.globalenv import VipyLogAdapter

@cocotb.test()
async def new_struct(dut) :
    tb = GlobalEnv().get_top(Hamster,dut)

    await tb.init()

    comptest = await tb.spi.read("COMPID",False)
    comptest = await tb.spi.read("COMPTEST",False)
    await Timer(1,"us")
    GlobalEnv()._log.lhigh(f"Write START")
    tb.spi.store_write("RADIOPOL.DIR_POL",1)
    tb.spi.store_write("RADIOPOL.OTHER_POL",1)
    tb.spi.store_write("RADIOCFGR.OTHER_CHAN",1)
    tb.spi.store_write("RADIO1DEAD",0xBEEF)
    tb.spi.compress_write()
    await tb.spi.send_write()

    GlobalEnv()._log.lhigh(f"Write done")
    await Timer(1,"us")

    radiopol = await tb.spi.read("RADIOPOL",False)
    radiocfgr = await tb.spi.read("RADIOCFGR",False)
    radio1dead = await tb.spi.read("RADIO1DEAD",False)




@cocotb.test()
async def new_spi(dut):
    await full_reset(dut)
    #itf = EncoderABI.ABIInterface(a=dut.i_enc1_a,b=dut.i_enc1_b,i=dut.i_enc1_i)
    # encoder = EncoderABI(300,itf=itf)
    # encoder.speed_tr_per_sec = 100000
    # await encoder.start()

    spi_itf = SPIInterface(
        mosi=dut.i_mosi,
        miso=dut.o_miso,
        clk=dut.i_spi_clk,
        csn=dut.i_cs_n
    )



    hamster = HamsterSPIInterface(spi_itf)
    cocotb.log.info("Hamster setup")

    clk = await cocotb.start(Clock(dut.i_clk,1,"ns").start())
    cocotb.log.info("Clock enabled")

    await Timer(100,"ns")
    dut.i_rst_n.value = 1
    await Timer(100,"ns")
    cocotb.log.info("Reset released")

    comptest = await hamster.read("COMPTEST",False)
    comptest = await hamster.read("COMPID",False)

    await Timer(1,"us")
    cocotb.log.info(f"Write START")
    hamster.store_write("RADIOPOL.DIR_POL",1)
    hamster.store_write("RADIOPOL.OTHER_POL",1)
    hamster.store_write("RADIOCFGR.OTHER_CHAN",1)
    hamster.store_write("RADIO1DEAD",0xBEEF)
    hamster.compress_write()
    await hamster.send_write()

    cocotb.log.info(f"Write done")
    await Timer(1,"us")

    radiopol = await hamster.read("RADIOPOL",False)
    radiocfgr = await hamster.read("RADIOCFGR",False)
    radio1dead = await hamster.read("RADIO1DEAD",False)


    return


@cocotb.test()
async def read_spi(dut):
    await full_reset(dut)

    itf = EncoderABI.ABIInterface(a=dut.i_enc1_a,b=dut.i_enc1_b,i=dut.i_enc1_i)
    encoder = EncoderABI(300,itf=itf)
    encoder.speed_tr_per_sec = 100000
    await encoder.start()

    spi_itf = SPIInterface(
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
    # MOT2 PWM
    spi_drv.to_send.put_nowait(spi_write(0x23))
    spi_drv.to_send.put_nowait(DataWord(1000))
    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    await Timer(1,"us")

    #Test
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
    
    
    await spi_drv.to_send.is_empty.wait()
    await spi_drv.evt.word_done.wait()
    await Timer(1,"us")
    # RADIOSKIP
    spi_drv.to_send.put_nowait(spi_read(0x17))
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

    itf = EncoderABI.ABIInterface(a=dut.i_enc1_a,b=dut.i_enc1_b,i=dut.i_enc1_i)
    encoder = EncoderABI(300,itf=itf)
    encoder.speed_tr_per_sec = 100000
    await encoder.start()

    spi_itf = SPIInterface(
        mosi=dut.i_mosi,
        miso=dut.o_miso,
        clk=dut.i_spi_clk,
        csn=dut.i_cs_n
    )

    spi_mode = 0
    spi_drv = SPIDriver(SerialMode.MASTER,spi_itf,(10,"ns"))
    spi_drv.csn_pulse_per_word = False
    spi_drv.spi_mode = spi_mode
    spi_drv.start()
    await Timer(1,"us")
    spi_drv.to_send.put_nowait(spi_write(0x30))
    spi_drv.to_send.put_nowait(DataWord(1000))
    await Timer(1,"us")
    # spi_drv.to_send.put_nowait(spi_write(0x20))
    # spi_drv.to_send.put_nowait(DataWord(1 << 6))

    dut.i_channels.value = 0b0010
    await ClockCycles(dut.i_clk,102+128 + 35)
    dut.i_channels.value = 0
    await Timer(50,"us")
    spi_drv.to_send.put_nowait(spi_write(0x20))
    spi_drv.to_send.put_nowait(DataWord(1 << 6))
    await Timer(25,"us")
    dut.i_channels.value = 0b0010
    await ClockCycles(dut.i_clk,102+128 + 86)
    dut.i_channels.value = 0
    await Timer(25,"us")
    clk.kill()
