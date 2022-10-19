`ifndef CMD_DECODER_H
`define CMD_DECODER_H

typedef struct packed {
	logic       valid      ;
	logic       write      ;
	logic       to_register;
	logic reset_spi;
	logic [7:0] payload    ;
} decoded_cmd_t;

const logic [7:0] K_CMD_READ = 8'h01;
const logic [7:0] K_CMD_WRITE = 8'h02;

`endif
