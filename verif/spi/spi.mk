# Makefile
SRC_PATH = $(PRJ_PATH)/rtl/spi
MODE ?= behav

ifeq ($(MODE),gate)
	VERILOG_SOURCES += /home/julien/Data/Linux/eda/pdk/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
	VERILOG_SOURCES += $(SRC_PATH)/phy/build/core_top/job0/physyn/0/outputs/core_top.vg
else
	VERILOG_SOURCES += $(SRC_PATH)/spi_slave.sv
endif

TOPLEVEL = spi_slave
TOPLEVEL_LANG = verilog