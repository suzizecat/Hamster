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

Task *hdl::Task::insert_task(Task *evt, bool push_last)
{
        femtosecond delta = evt->_delay;
        Task* next_evt = this;
        Task* last_evt = this;

        // Travel to the right position
        while(delta > next_evt->_delay && next_evt->_next != nullptr)
        {
            last_evt = next_evt;
            delta -= next_evt->_delay;
            next_evt = next_evt->_next;
        }

        // Push to last position of same timestep is requested
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
            // If we are before the first event.
            if(next_evt == this)
            {
               return evt;
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

        return this;
}

Task *hdl::Task::merge(Task *task_list)
{

    Task* next_task = task_list;
    Task* current_task = task_list;

    Task* ret = this;
    while(current_task != nullptr)
    {
        next_task = current_task->_next;
        ret = insert_task(current_task);
        current_task = next_task;
    }

    return ret;
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
    _log_format->set_pattern("[%*][%^%7l%$] %15C - %v");
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
        evt->_delay = delay;
        _evt_queue = _evt_queue->insert_task(evt, push_last);
    }
}

void hdl::BenchScheduler::schedule_net_event(Task* task, CData *net, EdgeKind edge)
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
    task->_delay = 0fs;
    holder.register_task(task);

    if(! task->is_virtual())
        _registered_netevt.got_scheduled_task = true;
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
        _validated_netevt.rising_edge[key].merge_tasks(registered_holder.registered_tasks);
    
    for(auto& [key,registered_holder] : _registered_netevt.falling_edge)
        _validated_netevt.falling_edge[key].merge_tasks(registered_holder.registered_tasks);

    for(auto& [key,registered_holder] : _registered_netevt.any_edge)
        _validated_netevt.any_edge[key].merge_tasks(registered_holder.registered_tasks);

    _registered_netevt.clear();
}

void BenchScheduler::NetEventRecords::clear()
{
    rising_edge.clear();
    falling_edge.clear();
    any_edge.clear();

}

bool hdl::BenchScheduler::NetEventRecords::is_empty()
{
    return rising_edge.empty() && falling_edge.empty() && any_edge.empty();
}

bool hdl::BenchScheduler::NetEventRecords::is_done()
{
    for(auto& [key, holder] : rising_edge)
    {
        if(! holder.registered_tasks->is_virtual())
            return false;
    }
    for(auto& [key, holder] : falling_edge)
    {
        if(! holder.registered_tasks->is_virtual())
            return false;
    }
    for(auto& [key, holder] : any_edge)
    {
        if(! holder.registered_tasks->is_virtual())
            return false;
    }
    return true;
}

bool BenchScheduler::process_nets_events()
{
    if(_validated_netevt.is_empty() && _registered_netevt.is_empty())
        return false;
    merge_nets_events();
    // The registered events are now validated.
    // Therefore, we can safely work on all validated events, they won't be changed.
    bool event_triggered = false;
    for (auto it = _validated_netevt.rising_edge.begin(); it != _validated_netevt.rising_edge.end();) // Do NOT increment here
    {
        CData* net = it->first;
        if(*net > it->second.registered_value)
        {
            event_triggered = true;
            // Equivalent to scheduling the woke-up tasks
            _evt_queue = _evt_queue->merge(it->second.registered_tasks);            
            it = _validated_netevt.rising_edge.erase(it);            
        }
        else
        {
            it->second.registered_value = *net;
            it++;
        }
    }
    
    for (auto it = _validated_netevt.falling_edge.begin(); it != _validated_netevt.falling_edge.end();) // Do NOT increment here
    {
        CData* net = it->first;
        if(*net < it->second.registered_value)
        {
            event_triggered = true;
            // Equivalent to scheduling the woke-up tasks
            _evt_queue = _evt_queue->merge(it->second.registered_tasks);            
            it = _validated_netevt.falling_edge.erase(it);            
        }
        else
        {
            it->second.registered_value = *net;
            it++;
        }
    }

    for (auto it = _validated_netevt.any_edge.begin(); it != _validated_netevt.any_edge.end();) // Do NOT increment here
    {
        CData* net = it->first;
        if(*net != it->second.registered_value)
        {
            event_triggered = true;
            // Equivalent to scheduling the woke-up tasks
            _evt_queue = _evt_queue->merge(it->second.registered_tasks);            
            it = _validated_netevt.any_edge.erase(it);            
        }
        else
        {
            it++;
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
    if( _evt_queue != nullptr && ! _evt_queue->is_virtual())
        return true;

    return ! (_validated_netevt.is_done() && _registered_netevt.is_done());
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

        // Process nets_events will reschedule tasks that have been woken up but without delay.
        // therefore, there will be a need to re-run the timestep.
        // For immediate events, reach_next_event should not have any effect.
        if (! process_nets_events())
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

void hdl::SignalEventHolder::register_task(Task *t)
{
    if(registered_tasks == nullptr)
    {
        registered_tasks = t;
    }
    else
    {
        registered_tasks = registered_tasks->insert_task(t);
    }
}

void hdl::SignalEventHolder::merge_tasks(Task *tl)
{
    if(registered_tasks == nullptr)
    {
        registered_tasks = tl;
    }
    else
    {
    registered_tasks = registered_tasks->merge(tl);
    }
}
