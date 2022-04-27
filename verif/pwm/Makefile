# Makefile
SRC_PATH = ../rtl
SYNTH_PATH=../../../synth/output
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

#VERILOG_SOURCES += $(SRC_PATH)/pwm_capture.sv
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__clkinv_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__dfrtp_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__dfxtp_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__nand2b_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__nor3_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__o21ai_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__o31a_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.sky130_fd_sc_ls__xnor2_1.v
# VERILOG_SOURCES += $(SYNTH_PATH)/design.pwm_capture.v

VERILOG_SOURCES += $(SYNTH_PATH)/mapped.full.v

# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = pwm_capture

# MODULE is the basename of the Python test file
MODULE = test_pwm
EXTRA_ARGS += --trace-fst --trace-structs
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim