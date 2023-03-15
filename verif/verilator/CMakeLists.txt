cmake_minimum_required(VERSION 3.12)
project(verilator_design)
find_package(verilator HINTS $ENV{VERILATOR_ROOT})

if(NOT TARGET spdlog)
    # Stand-alone build
    find_package(spdlog REQUIRED)
endif()

# add_subdirectory(cpp/thirdparty/fmt)
# add_subdirectory(cpp/thirdparty/spdlog)
#find_package(fmt)


add_executable(Vdut sim_main.cpp
cpp/generator.h
cpp/generator.cpp
cpp/hdltime.h

cpp/clock.h
cpp/clock.cpp

cpp/events/edge.h
cpp/events/edge.cpp
cpp/events/timer.h
cpp/events/timer.cpp

cpp/sim/spi.h
cpp/sim/spi.cpp


# cpp/event_queue.h
# cpp/event_queue.cpp

cpp/scheduler/sim_task_coro.h
cpp/scheduler/coro_scheduler.h
cpp/scheduler/coro_scheduler.cpp

cpp/dut.h
cpp/dut.cpp
)

include_directories(Vdut cpp)
target_link_libraries(Vdut PRIVATE fmt::fmt)
target_link_libraries(Vdut PRIVATE spdlog::spdlog)

set_property(TARGET Vdut PROPERTY CXX_STANDARD 20)
target_compile_options(Vdut PRIVATE -fcoroutines)

set(SRC_PATH $ENV{PRJ_PATH}/rtl)

verilate(Vdut SOURCES 
${SRC_PATH}/top/core_top.sv
${SRC_PATH}/top/spi_rb_interface.sv
${SRC_PATH}/top/cmd_decoder.sv
${SRC_PATH}/top/timebase.sv
${SRC_PATH}/top/channels_decoder.sv

${SRC_PATH}/pwm/pwm_capture.sv
${SRC_PATH}/maths/div.sv

${SRC_PATH}/regbank/reg_rdchan_if.sv
${SRC_PATH}/regbank/reg_wrchan_if.sv
${SRC_PATH}/regbank/hamster_regbank_in_if.sv
${SRC_PATH}/regbank/hamster_regbank_out_if.sv
${SRC_PATH}/regbank/hamster_regbank.sv

${SRC_PATH}/pwm/pwm_gen_left.sv

${SRC_PATH}/motor/pattern_generator.sv
${SRC_PATH}/motor/encoder_reader.sv
${SRC_PATH}/motor/speed_meter.sv
${SRC_PATH}/motor/motor_control_top.sv
${SRC_PATH}/motor/encoder_pwm_read.sv

${SRC_PATH}/spi/spi_slave.sv

TOP_MODULE core_top
TRACE_FST
PREFIX Vcore
VERILATOR_ARGS --relative-includes)
