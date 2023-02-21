#include "edge.h"
using namespace hdl;

void Edge::await_suspend(std::coroutine_handle<SimTaskCoro::promise_type> h)
{
    BenchScheduler& schd = BenchScheduler::get();
    schd.current_task()->_handle = h;
    schd.schedule_net_event(schd.current_task(), net, pol);
}