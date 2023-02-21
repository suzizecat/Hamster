#ifndef H_CORO_SCHEDULE
#define H_CORO_SCHEDULE

#include <functional>
#include <chrono>
#include <vector>
#include <coroutine>
#include <memory>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#include <verilated.h>
#include "hdltime.h"
#include "dut.h"
#include "spdlog/spdlog.h"
#include "spdlog/pattern_formatter.h"
#include "fmt/core.h"
#include "sim_task_coro.h"


namespace hdl{

// Forward declare Task
class Task;



struct SignalEventHolder
{
    SignalEventHolder() : registered_tasks(nullptr), initialized(false), registered_value(0) {};

    Task* registered_tasks;
    bool initialized;
    CData registered_value;

    void register_task(Task *t);
    void merge_tasks(Task* tl);

};


typedef enum  EdgeKind {Rising, Falling, Any} EdgeKind;

class BenchScheduler
{

    struct NetEventRecords
    {
        NetEventRecords() : got_scheduled_task(false), rising_edge(), falling_edge(), any_edge() {};
        std::unordered_map<CData*, SignalEventHolder > rising_edge;
        std::unordered_map<CData*, SignalEventHolder > falling_edge;
        std::unordered_map<CData*, SignalEventHolder > any_edge;

        void clear();
        bool is_empty();
        bool is_done();

        bool got_scheduled_task;
    };



    Task* _evt_queue;
    Task* _current_task;

    femtosecond _time;

    static BenchScheduler _self;

    NetEventRecords _validated_netevt;
    NetEventRecords _registered_netevt;
    
    ~BenchScheduler();
    BenchScheduler();

    public:
        BenchScheduler(const BenchScheduler&) = delete;
        BenchScheduler& operator=(const BenchScheduler&) = delete;

        static BenchScheduler& get() noexcept { return _self;}

        void schedule(Task* evt, femtosecond delay, const bool push_last = false);
        void schedule_net_event(Task* t, CData* net, EdgeKind edge = EdgeKind::Any );
        void run_time_step();
        void run_next_event();
        void merge_nets_events();
        bool process_nets_events();
        femtosecond get_next_event_time();
        bool got_remaining_events();
        bool is_timestep_done() const;
        void stop();
        Task* current_task() const;
        femtosecond time() const;
        femtosecond reach_next_event();

        void run(femtosecond timeout = 0fs);


    protected:
        Task* pop_event();

};


class Task
{
    friend class BenchScheduler;
        Task() = delete;

    public : 
        Task(std::coroutine_handle<SimTaskCoro::promise_type> handle, std::string name = "Unnamed", bool is_virtual = false, femtosecond schedule_time = 0fs);
        bool is_virtual() const {return ! ((! _is_virtual) || (_next != nullptr && ! _next->is_virtual()));};
        const std::string& get_name() const {return _name;};

        ~Task();
        std::coroutine_handle<SimTaskCoro::promise_type> _handle;
        Task* insert_task(Task *evt, bool push_last = false);
        Task* merge(Task *task_list);

    protected :
        femtosecond _delay;
        femtosecond _last_run_time;
        const bool _is_virtual;
        Task* _next;
        std::string _name;

        void _delete_following();

};


class SimTimeFormatFlag : public spdlog::custom_flag_formatter
{
public:
    void format(const spdlog::details::log_msg &, const std::tm &, spdlog::memory_buf_t &dest) override
    {
        //std::string content = fmt::memory_buffer();
        std::string content = fmt::format("{:12.2f} ns", BenchScheduler::get().time().count() / 1000000.0);
        dest.append(content.data(), content.data() + content.size());
    }

    std::unique_ptr<custom_flag_formatter> clone() const override
    {
        return spdlog::details::make_unique<SimTimeFormatFlag>();
    }
};

class SimCoroFlag : public spdlog::custom_flag_formatter
{
public:
    void format(const spdlog::details::log_msg &, const std::tm &, spdlog::memory_buf_t &dest) override
    {
        Task* t = BenchScheduler::get().current_task();
        const std::string& base = (t == nullptr) ? "" : ("sim." + t->get_name());
        
        std::string content = fmt::format("{:{}}",base,padinfo_.width_);
        dest.append(content.data(), content.data() + content.size());
    }

    std::unique_ptr<custom_flag_formatter> clone() const override
    {
        return spdlog::details::make_unique<SimCoroFlag>();
    }
};

}

#endif // H_CORO_SCHEDULE