#ifndef H_HDL_TIME
#define H_HDL_TIME

#include <chrono>

using picosecond = std::chrono::duration<int,std::pico>;
using femtosecond = std::chrono::duration<int,std::femto>;

#pragma GCC diagnostic ignored "-Wliteral-suffix"
#pragma GCC diagnostic push
constexpr picosecond operator ""ps(unsigned long long ps)
{
    return picosecond(ps);
};

constexpr femtosecond operator ""fs(unsigned long long fs)
{
    return femtosecond(fs);
};

#pragma GCC diagnostic pop

constexpr femtosecond NO_RESCHEDULE = -1fs;

#endif // H_HDL_TIME