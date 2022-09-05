module channels_decoder #(
	parameter int K_NCHAN = 4 ,
	parameter int K_RES   = 10
) (
	input  logic                                    i_clk           , //!
	input  logic                                    i_rst_n         , //!
	//Inputs
	input  logic [K_NCHAN-1:0][$clog2(K_NCHAN)-1:0] i_chan_route    , //!
	input  logic [K_NCHAN-1:0]                      i_channels      , //!
	input  logic [  K_RES-1:0]                      i_deadzone      , //!
	input  logic [  K_RES-1:0]                      i_skip_threshold, //!
	input  logic                                    i_timebase      , //!
	input  logic [K_NCHAN-1:0]                      i_polarity      , //!
	//Digital outputs
	output logic                                    o_boost         , //!
	output logic                                    o_beep          , //!
	output logic                                    o_rev           , //!
	output logic                                    o_brake         , //!
	output logic                                    o_direction     , //!
	// Analog values
	output logic [  K_RES-1:0]                      o_steer         ,
	output logic [  K_RES-1:0]                      o_power         , //!
	output logic                                    o_power_done
);

	localparam int K_CHAN_DIRECTION = 0;
	localparam int K_CHAN_POWER     = 1;
	localparam int K_CHAN_REV       = 2;
	localparam int K_CHAN_OTHER     = 3; //! pos = boost, neg = beep

	logic [$clog2(K_NCHAN)-1:0] direction_selection;
	logic [$clog2(K_NCHAN)-1:0] power_selection    ;
	logic [$clog2(K_NCHAN)-1:0] rev_selection      ;
	logic [$clog2(K_NCHAN)-1:0] other_selection    ;

	assign direction_selection = i_chan_route[K_CHAN_DIRECTION];
	assign power_selection     = i_chan_route[K_CHAN_POWER];
	assign rev_selection       = i_chan_route[K_CHAN_REV];
	assign other_selection     = i_chan_route[K_CHAN_OTHER];

	logic [K_NCHAN-1:0][K_RES-1:0] analog_values ;
	logic [K_NCHAN-1:0]            dig_values_pos;
	logic [K_NCHAN-1:0]            dig_values_neg;
	logic [K_NCHAN-1:0]            capture_done  ;

	generate
		for(genvar i = 0; i < K_NCHAN; i++) begin : gen_capture_channels
			logic             gen_capture_done ;
			logic [K_RES-1:0] gen_capture_value;
			logic             dead_value       ;

			pwm_capture #(.K_DWIDTH(K_RES)) u_pwm_capture (
				.i_clk          (i_clk            ),
				.i_rst_n        (i_rst_n          ),
				.i_timebase     (i_timebase       ),
				.i_pwm          (i_channels[i]    ),
				.i_polarity     (1'b0             ),
				.i_skip         (i_skip_threshold ),
				.o_capture_start(                 ),
				.o_capture_done (gen_capture_done ),
				.o_capture_value(gen_capture_value)
			);

			assign capture_done[i]   = gen_capture_done;
			assign analog_values[i]  = signed'(gen_capture_value) - signed'(K_RES'(2**(K_RES-1)));
			assign dead_value        = {1'b0,{(K_RES-1){analog_values[i][K_RES-1]}}^analog_values[i][K_RES-2:0]} < i_deadzone;
			assign dig_values_pos[i] = (~gen_capture_value[K_RES-1]) & (~dead_value);
			assign dig_values_neg[i] = ( gen_capture_value[K_RES-1]) & (~dead_value);

		end
	endgenerate

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_output
		if (~ i_rst_n ) begin
			o_beep      <= 0;
			o_boost     <= 0;
			o_brake     <= 0;
			o_direction <= 0;
			o_power     <= 0;
			o_rev       <= 0;
			o_steer     <= 0;

			o_power_done <= 0;
		end else begin
			o_power_done <= 0;
			if (capture_done[power_selection]) begin
				o_power <= analog_values[power_selection];
				o_brake <= i_polarity[power_selection] ? dig_values_neg[power_selection] : dig_values_pos[power_selection];

				o_power_done <= 1;
			end
			if (capture_done[direction_selection]) begin
				o_steer     <= analog_values[direction_selection];
				o_direction <= analog_values[direction_selection][K_RES-1] ^ i_polarity[direction_selection] ;
			end
			if(capture_done[rev_selection]) begin
				o_rev <= (~i_polarity[rev_selection]) ? dig_values_neg[rev_selection] : dig_values_pos[rev_selection];
			end
			if(capture_done[other_selection]) begin
				o_beep  <= (i_polarity[other_selection]) ? dig_values_neg[other_selection] : dig_values_pos[other_selection];;
				o_boost <= (~i_polarity[other_selection]) ? dig_values_neg[other_selection] : dig_values_pos[other_selection];;
			end
		end
	end

endmodule
