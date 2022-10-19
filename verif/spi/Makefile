# Makefile
# Sources
include ./spi.mk

# MODULE is the basename of the Python test file
SIM ?= verilator
MODULE ?= spi_verif_top
COMPILE_ARGS += --relative-includes
EXTRA_ARGS += --trace-fst --trace-structs

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
