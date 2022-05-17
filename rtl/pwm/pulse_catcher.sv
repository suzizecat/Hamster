module pulse_catcher #(parameter int K_CNTWIDTH = 16) (
	input  logic                  i_clk      , //!
	input  logic                  i_rst_n    , //!
	input  logic                  i_pulse    , //!
	input  logic [K_CNTWIDTH-1:0] i_threshold, //!
	output logic                  o_elapsed  , //!
	output logic                  o_rise     , //!
	output logic                  o_fall     , //!
	output logic [K_CNTWIDTH-1:0] o_cnt        //!
);

	logic prev_pulse_state;

	logic rise;
	logic fall;

	assign rise = ~prev_pulse_state & i_pulse;
	assign fall = prev_pulse_state & ~i_pulse;

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_counter
		if (~ i_rst_n ) begin
			
			o_cnt            <= 0;
			o_elapsed        <= 0;
			o_rise           <= 0;
			o_fall           <= 0;
			prev_pulse_state <= 0;

		end else begin

			o_elapsed        <= 0;
			o_rise           <= rise;
			o_fall           <= fall;
			prev_pulse_state <= i_pulse;

			if(rise) begin
				o_elapsed <= 0;
				o_cnt     <= 0;
			end else begin
				if (i_pulse) begin
					o_cnt <= o_cnt +1;
					o_elapsed <= (o_cnt == i_threshold) ? 1'b1 : 1'b0;
				end
			end
		end
	end

endmodule
