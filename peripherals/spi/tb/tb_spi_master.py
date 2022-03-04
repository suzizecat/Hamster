# -*- coding: utf-8 -*-
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge


@cocotb.test()
async def run_test(dut):
    clock = Clock(dut.clk,10,units="ns")
    cocotb.fork(clock.start())

    dut.clk <= 0
    dut.rstn <= 0
    dut.spi_clk <= 0
    dut.spi_csn <= 0
    dut.spi_miso <= 0
    for i in range(3) : await FallingEdge(dut.clk)
    dut.clk <= 1
    dut.rstn <= 1
    dut.spi_clk <= 1
    dut.spi_csn <= 1
    dut.spi_miso <= 1
    for i in range(3) : await FallingEdge(dut.clk)
