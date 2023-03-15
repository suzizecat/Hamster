#include "spi.h"

SPI::SPI(CData *csn, CData *clk, CData *mosi, CData *miso, femtosecond clk_period, int datasize, Mode mode) :
    _csn(csn),
    _clk(clk),
    _mosi(mosi),
    _miso(miso),
    _datasize(datasize),
    _half_period_active(clk_period/2),
    _half_period_idle(clk_period - clk_period/2),
    _rx_buffer(),
    _mode(mode)
{
}

void SPI::reset()
{
    *_csn = 1;
    *_mosi = 0;
    _set_clock(false);
}

const std::vector<int> &SPI::get_buffer() const
{
    return _rx_buffer;
}

void SPI::_set_clock(bool active)
{
    *_clk = ((_mode == Mode0 || _mode == Mode1) == active) ? 1 : 0;
}



hdl::SimTaskCoro SPI::exchange_data(const std::vector<int> datalist, bool keep_first_rx )
{
    _tx_buffer.clear();
    _tx_buffer.assign(datalist.cbegin(),datalist.cend());
    _rx_buffer.clear();
    *_csn = 0;
    _set_clock(false);

    co_await hdl::Timer(_half_period_active);
    
    for(int data : _tx_buffer)
    {
        int to_send = data & ((1 << _datasize) -1);
        int recieved = 0;
        spdlog::debug("Send 0x{:04X}",to_send);

        for(int i = _datasize -1; i >= 0; i--)
        {
            if(_mode == Mode0 || _mode == Mode2 )
            {
                *_mosi = (to_send >> i) & 1;
            } 
            else
            {
                recieved = (recieved << 1) | (*_miso & 1);
            }

            
            co_await hdl::Timer(_half_period_idle);
            _set_clock(true);

            if(_mode == Mode1 || _mode == Mode3 )
            {
                *_mosi = (to_send >> i) & 1;
            }
            else
            {
                recieved = (recieved << 1) | (*_miso & 1);
            }

            co_await hdl::Timer(_half_period_active);

            _set_clock(false);
        }

        _rx_buffer.push_back(recieved);
    }
    if(spdlog::get_level() <=  spdlog::level::debug)
    {
        std::string temp;
        for(int data : _tx_buffer)
            temp += fmt::format("0x{:0{}X} ", data,_datasize/4);
        spdlog::debug("Sent data : {}",temp);

        temp = "";
        for(int data : _rx_buffer)
            temp += fmt::format("0x{:0{}X} ", data,_datasize/4);
        spdlog::debug("Got data  : {}",temp);
    }

    if(! keep_first_rx)
    {
        _rx_buffer.erase(_rx_buffer.begin());
    }
    co_await hdl::Timer(_half_period_active);
    *_csn = 1;
    co_await hdl::Timer(_half_period_active);
}
