# Makefile
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
MODE ?= behav


include ../motor/motor.mk
include ../spi/spi.mk


SRC_PATH := $(PRJ_PATH)/rtl
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

VERILOG_SOURCES += $(SRC_PATH)/regbank/reg_rdchan_if.sv
VERILOG_SOURCES += $(SRC_PATH)/regbank/reg_wrchan_if.sv
VERILOG_SOURCES += $(SRC_PATH)/regbank/hamster_regbank_in_if.sv
VERILOG_SOURCES += $(SRC_PATH)/regbank/hamster_regbank_out_if.sv
VERILOG_SOURCES += $(SRC_PATH)/regbank/hamster_regbank.sv
VERILOG_SOURCES += $(SRC_PATH)/pwm/pwm_capture.sv
VERILOG_SOURCES += $(SRC_PATH)/maths/div.sv
VERILOG_SOURCES += $(SRC_PATH)/top/channels_decoder.sv
VERILOG_SOURCES += $(SRC_PATH)/top/timebase.sv
VERILOG_SOURCES += $(SRC_PATH)/top/spi_rb_interface.sv
VERILOG_SOURCES += $(SRC_PATH)/top/core_top.sv



# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = core_top

# MODULE is the basename of the Python test file
MODULE = new_test_top
COMPILE_ARGS += --relative-includes
#COMPILE_ARGS += -DFUNCTIONAL
EXTRA_ARGS += --trace-fst --trace-structs
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim