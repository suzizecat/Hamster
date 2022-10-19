
# Makefile
# Sources
# Makefile
SRC_PATH := $(PRJ_PATH)/rtl/
MODE ?= behav


VERILOG_SOURCES += $(SRC_PATH)/top/timebase.sv
VERILOG_SOURCES += $(SRC_PATH)/motor/prescaler_finder.sv


TOPLEVEL = prescaler_finder
TOPLEVEL_LANG = verilog

# MODULE is the basename of the Python test file
SIM ?= verilator
MODULE ?= test_$(TOPLEVEL)
COMPILE_ARGS += --relative-includes

EXTRA_ARGS += --trace-fst --trace-structs

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim