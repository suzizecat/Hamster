module speed_meter #(parameter int K_WIDTH = 32) (
	input  logic               i_clk         , //! System clock
	input  logic               i_rst_n       , //!
	input  logic               i_spd_trigger , //! Speed Event trigger
	input  logic               i_time_trigger, //! Time event trigger
	input  logic [K_WIDTH-1:0] i_step_size   , //! Step per event
	input  logic               i_force_reset , //! Force counted value to zero, no valid on rising edge
	input  logic               i_unlock      , //! Allow release of the counter at next step
	output logic [K_WIDTH-1:0] o_speed       , //!
	output logic               o_valid
);

	logic [K_WIDTH-1:0] cnt             ;
	logic               force_reset_prev;
	logic               req_unlock      ;


	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_speed_counter
		if (~ i_rst_n ) begin
			cnt              <= 0;
			o_speed          <= 0;
			o_valid          <= 0;
			force_reset_prev <= 1;
			req_unlock       <= 0;
		end else begin

			o_valid <= i_time_trigger;

			if (i_force_reset | force_reset_prev) begin
				cnt              <= 0;
				o_speed          <= 0;
				force_reset_prev <= 1;

				req_unlock <= (req_unlock | i_unlock) & ~i_force_reset ;
				if (i_time_trigger & (i_unlock | req_unlock)) begin
					force_reset_prev <= 0; // Unlock the counter
					req_unlock       <= 0;
				end
			end else begin
				if (i_time_trigger) begin
					cnt     <= 0;
					o_speed <= cnt;
				end else if (i_spd_trigger) begin
					cnt <= cnt + i_step_size;
				end
			end
		end
	end


endmodule
