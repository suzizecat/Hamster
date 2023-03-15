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
#include "events/edge.h"
#include <chrono>
#include "hdltime.h"
#include "sim/spi.h"

#include "clock.h"
using namespace std::chrono;



hdl::SimTaskCoro main_interaction()
{
    using namespace hdl;
    DUT& dut = DUT::get();
    SPI spi(&(dut.dut()->i_cs_n), &(dut.dut()->i_spi_clk), &(dut.dut()->i_mosi), &(dut.dut()->o_miso));
    spi.reset();
    spdlog::info("Start main");
    co_await RisingEdge(&(dut.dut()->i_rst_n));
    
    spdlog::info("End of reset detected");
    co_await Timer(10us);

    spdlog::info("Read the test register");
    
    new Task(spi.exchange_data({0x01A9, 0x0000},false), "spi");
    
    spdlog::info("Await end of transaction");
    co_await RisingEdge(&(dut.dut()->i_cs_n));
    co_await RisingEdge(&(dut.dut()->i_clk));

    new Task(spi.exchange_data({0x0100, 0x0000}));
    co_await RisingEdge(&(dut.dut()->i_cs_n));

    //
    spdlog::info("Component ID is 0x{:04X}",spi.get_buffer().at(0));
    spdlog::info("Transaction done");
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
    spdlog::set_level(spdlog::level::debug);
    using namespace std::chrono;
    spdlog::info("Start simulation");

    new hdl::Task(reset(),"rst");
    new hdl::Task(clock(5ns),"clk",true);
    new hdl::Task(main_interaction(),"spi",false,12ns);

    hdl::BenchScheduler::get().run(100000ns);
}