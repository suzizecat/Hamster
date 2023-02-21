#include "coro_scheduler.h"
#include "spdlog/cfg/env.h"
#include <stdexcept>

using namespace hdl;


BenchScheduler BenchScheduler::_self;

Task::Task(std::coroutine_handle<SimTaskCoro::promise_type> handle, std::string name, bool is_virtual, femtosecond schedule_time) :
    _handle(handle),
    _is_virtual(is_virtual),
    _next(nullptr), 
    _name(name),
    _last_run_time(-1fs)
{
    BenchScheduler::get().schedule(this,schedule_time,true);
}


Task::~Task()
{
    _handle.destroy();
    _delete_following();
}

void Task::_delete_following()
{
    if(_next != nullptr)
    {
        _next->_delete_following();
        delete _next;
    }
    _next = nullptr;
}

BenchScheduler::BenchScheduler() : _evt_queue(nullptr), _current_task(nullptr), _time(0fs) {
    auto _log_format = std::make_unique<spdlog::pattern_formatter>();
    _log_format->add_flag<SimTimeFormatFlag>('*');
    _log_format->add_flag<SimCoroFlag>('C');
    _log_format->set_pattern("[%*][%^%5l%$] %15C - %v");
    //_log_format->set_pattern("..");
    spdlog::cfg::load_env_levels();
    spdlog::set_formatter(std::move(_log_format));
}

hdl::BenchScheduler::~BenchScheduler()
{
    if(_evt_queue != nullptr)
        delete _evt_queue;

    if(_current_task != nullptr)
        delete _current_task;

    _evt_queue = nullptr;
    _current_task = nullptr;    
}

void BenchScheduler::schedule(Task *evt, femtosecond delay, const bool push_last)
{
    if(_evt_queue == nullptr)
    {
        _evt_queue = evt;
        evt->_delay = delay;
        return;
    }
    else
    {
        femtosecond delta = delay;
        Task* next_evt = _evt_queue;
        Task* last_evt = _evt_queue;

        while(delta > next_evt->_delay && next_evt->_next != nullptr)
        {
            last_evt = next_evt;
            delta -= next_evt->_delay;
            next_evt = next_evt->_next;
        }

        while(push_last && next_evt->_next != nullptr && next_evt->_next->_delay == 0fs)
        {
            // If requested, push the event to the end of the pile of event with same trigger timing.
            last_evt = next_evt;
            next_evt = next_evt->_next;
        }

        
        // Should schedule the event before the next_evt
        if(delta < next_evt->_delay)
        {
            evt->_delay = delta;
            evt->_next = next_evt;
            evt->_next->_delay -= delta;
            if(last_evt == _evt_queue)
            {
                _evt_queue = evt;
            }
            else
            {
                last_evt->_next = evt;
            }
        }
        else // We reached the end
        {
            evt->_delay = delta - next_evt->_delay;
            evt->_next = nullptr;
            next_evt->_next = evt;
        }
    }
}

void hdl::BenchScheduler::schedule_net_event(std::coroutine_handle<SimTaskCoro::promise_type> evt, CData *net, EdgeKind edge)
{
    std::unordered_map<CData*, SignalEventHolder>* selected_queue = nullptr;
    switch (edge)
    {
    case Rising:
        selected_queue = &(_registered_netevt.rising_edge);
        break;
    case Falling:
        selected_queue = &(_registered_netevt.falling_edge);
        break;
    default:
        selected_queue = &(_registered_netevt.any_edge);
        break;
    }

    SignalEventHolder& holder = (*selected_queue)[net];
    if(! holder.initialized)
    {
        holder.initialized = true;
        holder.registered_value = *net;
    }
    holder.registered_handles.insert(evt);
}

void BenchScheduler::run_time_step()
{
    if(get_next_event_time() > 0fs)
    {
        throw std::runtime_error("Try to run a timestep events without reaching it.");
    }

    Task* last_evt = nullptr;
    while(_evt_queue != nullptr && _evt_queue->_delay == 0fs)
    {

        if(last_evt == _evt_queue)
            throw std::runtime_error("Infinite loop : Event rescheduled without delay nor other events.");
        last_evt = _evt_queue;
        run_next_event();
    }
}

void BenchScheduler::merge_nets_events()
{
    _validated_netevt.rising_edge.merge(_registered_netevt.rising_edge);
    _validated_netevt.falling_edge.merge(_registered_netevt.falling_edge);
    _validated_netevt.any_edge.merge(_registered_netevt.any_edge);
    
    // If some events has been validated, but the event has not occured.
    for(auto& [key,registered_holder] : _registered_netevt.rising_edge)
        _validated_netevt.rising_edge[key].registered_handles.merge(registered_holder.registered_handles);
    
    for(auto& [key,registered_holder] : _registered_netevt.falling_edge)
        _validated_netevt.falling_edge[key].registered_handles.merge(registered_holder.registered_handles);

    for(auto& [key,registered_holder] : _registered_netevt.any_edge)
        _validated_netevt.any_edge[key].registered_handles.merge(registered_holder.registered_handles);

    _registered_netevt.clear();
}

void BenchScheduler::NetEventRecords::clear()
{
    rising_edge.clear();
    falling_edge.clear();
    any_edge.clear();
}

bool BenchScheduler::process_nets_events()
{
    merge_nets_events();
    // The registered events are now validated.
    // Therefore, we can safely work on all validated events, they won't be changed.
    bool event_triggered = false;
    for(auto& [net,holder] : _validated_netevt.rising_edge )
    {
        if(*net > holder.registered_value)
        {
            event_triggered = true;
            for(auto& handle : holder.registered_handles)
                handle();
            
            _validated_netevt.rising_edge.erase(net);
            // The iterator is now invalid, should go next to get a clean iterator
            
        }
        else
        {
            holder.registered_value = *net;
        }
    }
    
    for(auto& [net,holder] : _validated_netevt.falling_edge )
    {
        if(*net < holder.registered_value)
        {
            event_triggered = true;
            for(auto& handle : holder.registered_handles)
                handle();
            
            _validated_netevt.rising_edge.erase(net);
            // The iterator is now invalid, should go next to get a clean iterator
            continue;
        }
        else
        {
            holder.registered_value = *net;
        }
    }

    for(auto& [net,holder] : _validated_netevt.any_edge )
    {
        if(*net != holder.registered_value)
        {
            event_triggered = true;
            for(auto& handle : holder.registered_handles)
                handle();
            
            _validated_netevt.rising_edge.erase(net);
            // The iterator is now invalid, should go next to get a clean iterator
            continue;
        }
    }

    return event_triggered;
}

Task* BenchScheduler::pop_event()
{
    if (_evt_queue == nullptr)
        throw std::out_of_range("Called 'pop' on an empty event queue");

    Task* ret = _evt_queue;
    _evt_queue = ret->_next;
    ret->_next = nullptr;

    return ret;
}

void BenchScheduler::run_next_event()
{

    _current_task = pop_event();
    
    _current_task->_handle();

    // All rescheduling will be handle through awaitable.

    if(! _current_task->_handle || _current_task->_handle.done())
    {
        spdlog::info("Task done");
        delete _current_task;

    }

    _current_task = nullptr;
}

femtosecond BenchScheduler::get_next_event_time()
{
    return _evt_queue->_delay;
}

bool BenchScheduler::got_remaining_events()
{
    Task* evt = _evt_queue;
    while(evt != nullptr)
    {
        if(evt->_is_virtual)
            evt = evt->_next;
        else
            return true;
    }
    return false;
}

bool BenchScheduler::is_timestep_done() const
{
    if(_evt_queue != nullptr)
    {
        return _evt_queue->_delay > 0fs;
    }
    else
    {
        return true;
    }
}


Task* hdl::BenchScheduler::current_task() const
{
    return _current_task;
}

femtosecond BenchScheduler::time() const
{
    return _time;
}

femtosecond BenchScheduler::reach_next_event()
{
    femtosecond ret;
    ret = _evt_queue->_delay;
    _evt_queue->_delay = 0fs;
    _time += ret;
    return ret;
}

void hdl::BenchScheduler::stop()
{
    spdlog::info("Simulation stop() called");
    if(got_remaining_events())
        spdlog::warn("Remaining coroutines will be killed.");
    else if (_evt_queue != nullptr)
        spdlog::debug("Remaining virtual coroutines will be killed.");

    if(_evt_queue != nullptr)
    {    
        delete _evt_queue;    
        _evt_queue = nullptr;
    }

    spdlog::info("All coroutines killed, end of simulation at {} ns",_time.count()/1e6);
}

void hdl::BenchScheduler::run(femtosecond timeout)
{
    DUT& dut = DUT::get();
    while(got_remaining_events() && (timeout < 0fs || _time < timeout))
    {
        reach_next_event();
        while(! is_timestep_done())
            run_time_step();

        dut.eval();

        while(process_nets_events())
            dut.eval();
        
        dut.trace(_time.count()/1000);
    }

    if(timeout > 0fs && _time >= timeout)
        spdlog::warn("Simulation ended on timeout.");
    else if (! got_remaining_events())
        spdlog::info("Simulation ran out of non-virtual coroutines.");
    else
        spdlog::error("Simulation somehow ended in an unexpected way.");
    
    stop();
}

