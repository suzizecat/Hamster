`include "decoder.svh"
//
// typedef struct packed {
// 	logic       valid      ;
// 	logic       write      ;
// 	logic       to_register;
// 	logic [7:0] payload    ;
// } decoded_cmd_t;

module cmd_decoder (
	input  logic         i_clk      , //!
	input  logic         i_rst_n    , //!
	input  logic         i_spi_csn  , //!
	input  logic [15:0]  i_spi_data , //!
	input  logic         i_spi_valid, //!
	output decoded_cmd_t o_command
);

	logic [7:0] part_cmd    ;
	logic [7:0] part_payload;

	logic         locked  ;
	decoded_cmd_t next_cmd;

	assign {part_cmd,part_payload} = i_spi_data;

	always_comb begin : p_comb_decode
		next_cmd       = 0;
		next_cmd.valid = 1;
		case (part_cmd)
			K_CMD_READ :
				begin
					next_cmd.to_register = 1;
					next_cmd.write       = 0;
					next_cmd.payload     = part_payload;
				end
			K_CMD_WRITE :
				begin
					next_cmd.to_register = 1;
					next_cmd.write       = 1;
					next_cmd.payload     = part_payload;
				end
			default : begin
				next_cmd = 0;
			end
		endcase
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_process
		if (~ i_rst_n ) begin
			locked    <= 0;
			o_command <= 0;
		end else begin
			o_command.valid <= 0;
			o_command.reset_spi <= 0;
			if(i_spi_csn) begin
				locked              <= 0;
				o_command           <= 0;
				o_command.reset_spi <= 1;
			end else begin
				if(i_spi_valid & ~locked) begin
					locked    <= next_cmd.valid;
					o_command <= next_cmd;
				end
			end
		end
	end

endmodule
