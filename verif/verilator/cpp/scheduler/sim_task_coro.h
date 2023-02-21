#ifndef _H_INCLUDE_SIMTASKCORO
#define _H_INCLUDE_SIMTASKCORO

#include <coroutine>

namespace hdl
{
    struct SimTaskCoro
    {
        struct promise_type
        {
            SimTaskCoro get_return_object()
            {
                return {.h = std::coroutine_handle<promise_type>::from_promise(*this)};
            };
            std::suspend_always initial_suspend() { return {}; }
            std::suspend_always final_suspend() noexcept { return {}; }

            // If actions have to be done on exiting the coroutine,
            // implement return_void()
            void return_void() {}
            void unhandled_exception() {}
        };

        std::coroutine_handle<promise_type> h;

        // Add support for direct call of the coroutine handle
        // A coroutine_handle<promise_type> converts to coroutine_handle<>
        operator std::coroutine_handle<promise_type>() const { return h; }
        operator std::coroutine_handle<>() const { return h; }
    };
} // namespace hdl

#endif //_H_INCLUDE_SIMTASKCORO