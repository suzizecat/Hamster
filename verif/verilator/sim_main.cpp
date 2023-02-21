#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_fst_c.h>
#include "Vcore.h"
#include "spdlog/spdlog.h"
#include "dut.h"
#include <coroutine>
#include  "scheduler/coro_scheduler.h"
#include  "hdltime.h"
#include  "events/timer.h"
#include "generator.h"

#include <chrono>
#include "hdltime.h"

#include "clock.h"
using namespace std::chrono;


hdl::SimTaskCoro addition()
{
    using namespace hdl;
    spdlog::info("Set inputs");
    DUT::get().dut()->i_channels = 2;
    co_await Timer(20ns);
    
    DUT::get().dut()->i_channels = 1;
    co_await Timer(20ns);
    
    DUT::get().dut()->i_channels = 0;
    co_await Timer(100ns);
    
    DUT::get().dut()->i_channels = 3;
    co_await Timer(10ns);

}


hdl::SimTaskCoro reset()
{
    using namespace hdl;
    co_await Timer(10ns);
    
    DUT::get().dut()->i_rst_n = 1;
    co_await Timer(10ns);

    DUT::get().dut()->i_rst_n = 0;
    co_await Timer(100ns);

    spdlog::info("Release reset");
    DUT::get().dut()->i_rst_n = 1;

    new Task(addition(),"add",false,12ns);
}

hdl::SimTaskCoro clock(femtosecond period)
{
    using namespace hdl;
    
    while(true)
    {
        DUT::get().toggle_clock();
        co_await Timer(period);
    }
}

 int main(int argc, char** argv, char** env) {
    DUT::get().setup();

    using namespace std::chrono;
    spdlog::info("Start simulation");

    new hdl::Task(reset(),"rst");
    new hdl::Task(clock(5ns),"clk",true);

    hdl::BenchScheduler::get().run(1us);
}