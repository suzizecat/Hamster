#ifndef _H_INCLUDE_CLOCK
#define _H_INCLUDE_CLOCK

#include "verilated.h"
#include "hdltime.h"
#include "dut.h"
#include "generator.h"
namespace hdl
{
    class Clock
    {
        protected:
        CData* _net;
        femtosecond _half_period;
        CData _reset_value;
        public:
        Clock(CData* clock_net, femtosecond period, CData idle_value = 0);

        util::Generator<femtosecond> reset();
        util::Generator<femtosecond> operator()();
    };
} // namespace hdl

#endif //_H_INCLUDE_CLOCK