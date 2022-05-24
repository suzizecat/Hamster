# Makefile
SRC_PATH := $(PRJ_PATH)/rtl/motor
MODE ?= behav

VERILOG_SOURCES := $(VERILOG_SOURCES) 
VERILOG_SOURCES += $(SRC_PATH)/pattern_generator.sv


TOPLEVEL = pattern_generator
TOPLEVEL_LANG = verilog