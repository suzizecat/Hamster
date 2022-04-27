module pwm_gen_left #(parameter int K_RES = 16) (
	input  logic             i_clk      , //! Master clock
	input  logic             i_rst_n    , //! Master reset
	input  logic             i_enable   , //! Enable input
	input  logic [K_RES-1:0] i_max      , //! Max value of the counter
	input  logic [K_RES-1:0] i_threshold, //! Threshold
	output logic             o_pwm        //! PWM output
);

	logic [K_RES-1:0] cnt      ;
	logic [K_RES-1:0] max      ;
	logic [K_RES-1:0] threshold;

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_pwm_gen
		if ( ~ i_rst_n ) begin
			cnt <= 0;
			max <= 0;
			o_pwm <= 0;
			threshold <= 0;
		end else begin
			if (~i_enable) begin
				cnt   <= 0;
				o_pwm <= 0;
			end else begin
				cnt <= (cnt == max) ? 0 : (cnt +1);
				o_pwm <= cnt < threshold;
				if (cnt == 0) begin
					max       <= i_max;
					threshold <= i_threshold;
				end
			end
		end
	end

endmodule
