# Makefile
SRC_PATH = ../rtl

SYNTH_PATH=../../../synth/output
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

# VERILOG_SOURCES += $(SRC_PATH)/pattern_generator.sv
# VERILOG_SOURCES += $(SRC_PATH)/encoder_reader.sv
VERILOG_SOURCES += $(SRC_PATH)/motor_control_top.sv

COMPILE_ARGS += -I../rtl
COMPILE_ARGS += -I../../pwm/rtl
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = motor_control_top

# MODULE is the basename of the Python test file
MODULE = test_$(TOPLEVEL)
EXTRA_ARGS += --trace-fst --trace-structs
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim