# Makefile
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
MODE ?= behav

SIM_BUILD ?= sim_build_$(MODE)


ifeq ($(MODE), behav)
$(info "Mode is behav")
include ../motor/motor.mk
include ../spi/spi.mk
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SRC_PATH := $(PRJ_PATH)/rtl
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
COMPILE_ARGS += --relative-includes
else
$(info "Mode is gate")
SRC_PATH := $(PRJ_PATH)/phy/build/core_top/job0
COMPILE_ARGS += -Wno-WIDTH
VERILOG_SOURCES += /home/julien/Projets/C++/Libety/sky130_fd_sc_hd__tt_025C_1v80.v
VERILOG_SOURCES += $(SRC_PATH)/syn/0/outputs/core_top.vg
endif


# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = core_top

# MODULE is the basename of the Python test file
MODULE = new_test_top

#COMPILE_ARGS += -DFUNCTIONAL
EXTRA_ARGS += --trace-fst --trace-structs
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim