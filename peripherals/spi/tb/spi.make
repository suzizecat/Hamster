# Makefile
SRC_PATH = ../rtl
CUSTOM_MAKEFILE = spi.make
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/if_spi.sv
VERILOG_SOURCES += $(SRC_PATH)/spi_master.sv
VERILOG_SOURCES += spi_master_wrapper.sv
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = spi_master_wrapper
export COCOTB_REDUCED_LOG_FMT=1

# MODULE is the basename of the Python test file
MODULE = tb_spi_master

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim