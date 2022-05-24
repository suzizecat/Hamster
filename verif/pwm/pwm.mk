# Makefile
MODE ?= behav

SRC_PATH := $(PRJ_PATH)/rtl/pwm
VERILOG_SOURCES := $(VERILOG_SOURCES) 
VERILOG_SOURCES += $(SRC_PATH)/pwm_gen_left.sv

TOPLEVEL = pwm_gen_left
TOPLEVEL_LANG = verilog