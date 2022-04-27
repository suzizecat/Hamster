# Makefile
SRC_PATH = ../rtl
SYNTH_PATH=../../../synth/output
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SRC_PATH)/pattern_generator.sv
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = pattern_generator

# MODULE is the basename of the Python test file
MODULE = test_pattern_generator
EXTRA_ARGS += --trace-fst --trace-structs
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim