#include "clock.h"

hdl::Clock::Clock(CData *clock_net, femtosecond period, CData idle_value) :
 _net(clock_net),
 _half_period(period/2),
 _reset_value(idle_value)
{}

hdl::util::Generator<femtosecond> hdl::Clock::reset()
{
    *_net = _reset_value;
    co_return;
}

hdl::util::Generator<femtosecond> hdl::Clock::operator()()
{
    for(;;)
    {
        *_net ^= 1;
        DUT::eval();
        co_yield _half_period;
    }
}
