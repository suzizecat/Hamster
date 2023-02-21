#ifndef _H_INCLUDE_BASE_EVENT
#define _H_INCLUDE_BASE_EVENT

#include "../scheduler/sim_task_coro.h"
#include <vector>
#include <set>
#include <verilated.h>

namespace hdl
{
    struct SignalEventHolder
    {
        SignalEventHolder() : registered_handles(), initialized(false), registered_value(0) {};

        std::set<std::coroutine_handle<SimTaskCoro::promise_type> > registered_handles;
        bool initialized;
        CData registered_value;   
    };

    typedef enum  EdgeKind {Rising, Falling, Any} EdgeKind;

}
#endif //_H_INCLUDE_BASE_EVENT