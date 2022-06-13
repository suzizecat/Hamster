# Makefile
MODE ?= behav
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(SELF_DIR)/pattern_generator/pattern_generator.mk
include $(SELF_DIR)/../pwm/pwm.mk

SRC_PATH := $(PRJ_PATH)/rtl/motor
VERILOG_SOURCES := $(VERILOG_SOURCES) 
VERILOG_SOURCES += $(SRC_PATH)/encoder_reader.sv
VERILOG_SOURCES += $(SRC_PATH)/speed_meter.sv
VERILOG_SOURCES += $(SRC_PATH)/motor_control_top.sv


TOPLEVEL = motor_control_top
TOPLEVEL_LANG = verilog