#ifndef _H_INCLUDE_SPI
#define _H_INCLUDE_SPI

#include <verilated.h>
#include <chrono>
#include <coroutine>

#include "hdltime.h"
#include "scheduler/sim_task_coro.h"
#include "events/timer.h"
#include "events/edge.h"
#include <vector>
#include <queue>
#include "spdlog/spdlog.h"
#include "fmt/core.h"

using namespace std::chrono;
class SPI
{
    public:
        typedef enum {Mode0 = 0, Mode1, Mode2, Mode3} Mode;
        SPI(CData* csn, CData* clk, CData* mosi, CData* miso, femtosecond clk_period = 1us, int data_size = 16, Mode mode = Mode0);
        void reset();
        const std::vector<int>& get_buffer() const;
        hdl::SimTaskCoro exchange_data(const std::vector<int> datalist, bool keep_first_rx = false);
        

    protected:
        void _set_clock(bool active);

        CData* _csn;
        CData* _clk;
        CData* _mosi;
        CData* _miso;
        int _datasize;
        femtosecond _half_period_active;
        femtosecond _half_period_idle;
        std::vector<int> _rx_buffer;
        std::vector<int> _tx_buffer;
        Mode _mode;
};

#endif //_H_INCLUDE_SPI