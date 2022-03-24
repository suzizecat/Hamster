# Makefile
SRC_PATH = ../../../
SYNTH_PATH=../../../synth/output
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
MODE ?= behav

ifeq ($(MODE),gate)
	VERILOG_SOURCES += /home/julien/Data/Linux/eda/pdk/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
	VERILOG_SOURCES += $(SRC_PATH)/phy/build/core_top/job0/physyn/0/outputs/core_top.vg
else
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/motor/rtl/encoder_reader.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/motor/rtl/motor_control_top.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/motor/rtl/pattern_generator.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/regbank/rtl/reg_rdchan_if.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/regbank/rtl/reg_wrchan_if.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/regbank/rtl/hamster_regbank_in_if.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/regbank/rtl/hamster_regbank_out_if.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/regbank/rtl/hamster_regbank.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/pwm/rtl/pwm_gen_left.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/pwm/rtl/pwm_capture.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/spi/rtl/spi_slave.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/top/rtl/channels_decoder.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/top/rtl/spi_rb_interface.sv
	VERILOG_SOURCES += $(SRC_PATH)/peripherals/top/rtl/core_top.sv
endif


# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = core_top

# MODULE is the basename of the Python test file
MODULE = test_top
COMPILE_ARGS += --relative-includes
#COMPILE_ARGS += -DFUNCTIONAL
EXTRA_ARGS += --trace-fst --trace-structs
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim