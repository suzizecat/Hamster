#ifndef _H_INCLUDE_TIMER
#define _H_INCLUDE_TIMER

#include "hdltime.h"
#include "scheduler/coro_scheduler.h"

namespace hdl
{

struct Timer
{
    Timer(const femtosecond delay = 0fs): delay(delay) {} ;
    const femtosecond delay;
    //Usage will be co_await Timer(1us); 

    // Always suspend the coroutine.
    // Might change depending on the time we want to await.
    constexpr bool await_ready() const noexcept {return delay < 0fs;}
    
    // On await suspend, reschedule the task.
    void await_suspend(std::coroutine_handle<SimTaskCoro::promise_type> h);
    
    // Might return the value of the co_await expression.
    // Here nothing required.
    constexpr void await_resume() const noexcept {}
};

}

#endif //_H_INCLUDE_TIMER