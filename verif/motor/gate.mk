# Makefile
SRC_PATH = ../rtl
SYNTH_PATH=../../../synth/output
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(SYNTH_PATH)/mapped.full.sim.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL ?= motor_control_top

# MODULE is the basename of the Python test file
MODULE = test_$(TOPLEVEL)
# COMPILE_ARGS += -Wno-WIDTH
# COMPILE_ARGS += -Wno-UNOPT
# COMPILE_ARGS += -Wno-CASEOVERLAP
EXTRA_ARGS += --trace-fst --trace-structs
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim