#include "dut.h"
#include "spdlog/spdlog.h"



DUT DUT::_self;

DUT::DUT() : _sim_time(0)
{
    spdlog::debug("Instanciate the DUT");
    _dut = std::make_unique<Vcore>();
    Verilated::traceEverOn(true);

}

void DUT::setup()
{
    spdlog::debug("Create the tracer");
    _trace = new VerilatedFstC();
    _dut->trace(_trace,5);
    spdlog::debug("Open the waveform file");
    _trace->open("waveform.fst");
    spdlog::debug("Setup done");
}

DUT::~DUT()
{
    spdlog::debug("Delete the DUT");
    _trace->close();

}

void DUT::toggle_clock()
{
    _dut->i_clk ^= 1;
    _dut->eval();
}

void DUT::trace(const int timestep)
{
    _trace->dump(timestep);
}

Vcore* DUT::dut()
{
    return _dut.get();
}