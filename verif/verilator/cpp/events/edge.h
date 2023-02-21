#ifndef _H_INCLUDE_EDGE_EVENT
#define _H_INCLUDE_EDGE_EVENT

#include "verilated.h"
#include "hdltime.h"
#include "../scheduler/coro_scheduler.h" 

namespace hdl
{

struct Edge
{
    Edge(CData* net, EdgeKind polarity = Any): net(net), pol(polarity) {} ;
    CData* net;
    EdgeKind pol;
    //Usage will be co_await Timer(1us); 

    // Always suspend the coroutine.
    // Might change depending on the time we want to await.
    constexpr bool await_ready() const noexcept {return false;}
    
    // On await suspend, reschedule the task.
    void await_suspend(std::coroutine_handle<SimTaskCoro::promise_type> h);
    
    // Might return the value of the co_await expression.
    // Here nothing required.
    constexpr void await_resume() const noexcept {}
};

struct RisingEdge : Edge
{
    RisingEdge(CData* net): Edge(net, Rising) {} ;
};

struct FallingEdge : Edge
{
    FallingEdge(CData* net): Edge(net, Falling) {} ;
};

struct AnyEdge : Edge
{
    AnyEdge(CData* net): Edge(net, Any) {} ;
};

}


#endif //_H_INCLUDE_EDGE_EVENT