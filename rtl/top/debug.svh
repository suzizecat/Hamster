`ifndef DEBUG_ITF_H
`define DEBUG_ITF_H

typedef struct packed {
    logic clk_r;
    logic clk_f;	
    logic selected;
    logic rx_evt;
    logic txe;
    logic [3:0] rx_cnt;
    logic [3:0] tx_cnt;
    logic [15:0] rx_data;
} spi_events_t;

`endif
