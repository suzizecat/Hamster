module timebase #(parameter int K_RES = 32) (
	input  logic             i_clk  , //!
	input  logic             i_rst_n, //!
	input  logic             i_stop , //!
	input  logic [K_RES-1:0] i_thr  , //!
	output logic             o_tick   //!
);

	logic [K_RES-1:0] cnt;


	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_
		if (~ i_rst_n ) begin
			o_tick <= 0;
			cnt    <= 0;
		end else begin
			o_tick <= cnt == i_thr;
			if (i_stop || cnt >= i_thr) begin
				cnt <= 0;
			end else begin
				cnt <= cnt +1;
			end
		end
	end

endmodule

