# Makefile
SRC_PATH = ../rtl

SYNTH_PATH=../../../synth/output
# defaults
SIM ?= verilator

include ./motor.mk

COMPILE_ARGS += -I../rtl
COMPILE_ARGS += -I../../pwm/rtl
# COMPILE_ARGS += --threads 6
# COMPILE_ARGS += --threads-dpi all

# MODULE is the basename of the Python test file
MODULE = test_$(TOPLEVEL)
EXTRA_ARGS += --trace-fst 
EXTRA_ARGS += --trace-structs 
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
