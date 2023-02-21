#include "event_queue.h"
#include <stdexcept>
#include "coro_scheduler.h"
Task::Task(std::function<femtosecond()> fct, bool is_virtual) : 
    fct(fct), 
    _is_virtual(is_virtual),
    _remaining_time(-1fs),
    _next(nullptr)
{

}


Task::~Task()
{
    _delete_following();
}

femtosecond Task::get_remaining_duration() const
{
    return _remaining_time;
}

void Task::_delete_following()
{
    if(_next != nullptr)
    {
        _next->_delete_following();
        delete _next;
    }
}

TaskScheduler::TaskScheduler() : _evt_queue(nullptr)
{}

TaskScheduler::~TaskScheduler()
{   
    if(_evt_queue != nullptr)
    {
        _evt_queue->_delete_following();
        delete _evt_queue;
    }
}

void TaskScheduler::schedule(Task* evt, femtosecond delay, const bool push_last)
{
    if(_evt_queue == nullptr)
    {
        _evt_queue = evt;
        evt->_remaining_time = delay;
        return;
    }
    else
    {
        femtosecond delta = delay;
        Task* next_evt = _evt_queue;
        Task* last_evt = _evt_queue;

        while(delta > next_evt->_remaining_time && next_evt->_next != nullptr)
        {
            last_evt = next_evt;
            delta -= next_evt->_remaining_time;
            next_evt = next_evt->_next;
        }

        while(push_last && next_evt != nullptr && next_evt->_next->_remaining_time == 0fs)
        {
            // If requested, push the event to the end of the pile of event with same trigger timing.
            last_evt = next_evt;
            next_evt = next_evt->_next;
        }

        
        // Should schedule the event before the next_evt
        if(delta < next_evt->_remaining_time)
        {
            evt->_remaining_time = delta;
            evt->_next = next_evt;
            evt->_next->_remaining_time -= delta;
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
            evt->_remaining_time = delta - next_evt->_remaining_time;
            evt->_next = nullptr;
            next_evt->_next = evt;
        }
    }
}

void TaskScheduler::run_time_step()
{
    if(get_next_event_time() > 0fs)
    {
        throw std::runtime_error("Try to run a timestep events without reaching it.");
    }

    Task* last_evt = nullptr;
    while(_evt_queue != nullptr && _evt_queue->_remaining_time == 0fs)
    {
        if(last_evt == _evt_queue)
            throw std::runtime_error("Infinite loop : Event rescheduled without delay nor other events.");
         run_next_event();
    }
}

Task* TaskScheduler::pop_event()
{
    if (_evt_queue == nullptr)
        throw std::out_of_range("Called 'pop' on an empty event queue");

    Task* ret = _evt_queue;
    _evt_queue = ret->_next;
    ret->_next = nullptr;

    return ret;
}

void TaskScheduler::run_next_event()
{

    Task* _evt = pop_event();
    femtosecond reschedule_time = _evt->fct();
    if (reschedule_time > 0fs)
    {
        schedule(_evt,reschedule_time);
    }
    else if (reschedule_time == 0fs)
    {
        schedule(_evt,0fs,true);
    }
    else
    {
        delete _evt;
    }
}

femtosecond TaskScheduler::get_next_event_time()
{
    return _evt_queue->get_remaining_duration();
}

bool TaskScheduler::got_remaining_events()
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

bool TaskScheduler::is_timestep_done() const
{
    if(_evt_queue != nullptr)
    {
        return _evt_queue->get_remaining_duration() > 0fs;
    }
    else
    {
        return true;
    }
}

femtosecond TaskScheduler::reach_next_event()
{
    femtosecond ret;
    ret = _evt_queue->_remaining_time;
    _evt_queue->_remaining_time = 0fs;
    return ret;
}
