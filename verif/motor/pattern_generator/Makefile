# Makefile
# Sources
include ./pattern_generator.mk

# MODULE is the basename of the Python test file
SIM ?= verilator
MODULE ?= pattern_gen_verif_top
COMPILE_ARGS += --relative-includes
EXTRA_ARGS += --trace-fst --trace-structs

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim