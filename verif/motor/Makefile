# Makefile
SRC_PATH = ../rtl

SYNTH_PATH=../../../synth/output
# defaults
SIM ?= verilator
MODE ?= behav
TOPLEVEL ?= motor_control_top
SIM_BUILD ?= sim_build_$(MODE)

ifeq ($(MODE),"behav")
$(info "Running behavioral mode")
include ./motor.mk

COMPILE_ARGS += -I../rtl
COMPILE_ARGS += -I../../pwm/rtl

# MODULE is the basename of the Python test file

else
$(info "Running gate mode")
SRC_PATH := $(PRJ_PATH)/phy/build/$(TOPLEVEL)/job0
COMPILE_ARGS += -Wno-WIDTH
VERILOG_SOURCES += /home/julien/Projets/C++/Libety/sky130_fd_sc_hd__tt_025C_1v80.v
VERILOG_SOURCES += $(SRC_PATH)/syn/0/outputs/$(TOPLEVEL).vg
endif

MODULE = test_$(TOPLEVEL)

EXTRA_ARGS += --trace-fst 
EXTRA_ARGS += --trace-structs 
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
