#include "timer.h"
using namespace hdl;

void Timer::await_suspend(std::coroutine_handle<SimTaskCoro::promise_type> h)
{
    BenchScheduler& schd = BenchScheduler::get();
    schd.current_task()->_handle = h;
    schd.schedule(schd.current_task(),delay,true);
}