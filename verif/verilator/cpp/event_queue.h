#ifndef H_EVENT_QUEUE
#define H_EVENT_QUEUE

#include <functional>
#include <chrono>
#include "hdltime.h"
#include <vector>

struct Task
{
    public : 
        friend class TaskScheduler;

        Task(std::function<femtosecond()> fct, bool is_virtual = false);
        ~Task();
        std::function<femtosecond()> fct;

        femtosecond get_remaining_duration() const;
        constexpr bool is_virtual() const {return _is_virtual;};
    
    protected:
        const  bool _is_virtual;
        femtosecond _remaining_time;
        Task* _next;
        void _delete_following();

};

class Event
{
    protected:
        std::vector<std::function<void()>> _awaiting_functions;
        bool _triggered;


    public:
        Event();
        bool is_triggered() const;
        void set();
        void clear();
        void add_to_awaiting_list(std::function<void()> f);
    
};

class TaskScheduler
{
    Task* _evt_queue;

    public:
        TaskScheduler();
        ~TaskScheduler();

        void schedule(Task* evt, femtosecond delay, const bool push_last = false);
        void run_time_step();
        void run_next_event();
        femtosecond get_next_event_time();
        bool got_remaining_events();
        bool is_timestep_done() const;
        femtosecond reach_next_event();


    protected:
        Task* pop_event();
};

#endif // H_EVENT_QUEUE