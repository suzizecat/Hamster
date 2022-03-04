module channels_decoder #(
	parameter int K_NCHAN = 4 ,
	parameter int K_RES   = 10
) (
	input  logic               i_clk      , //!
	input  logic               i_rst_n    , //!
	//Inputs
	input  logic [K_NCHAN-1:0] i_channels , //!
	input  logic [  K_RES-1:0] i_deadzone , //!
	input  logic               i_timebase , //!
	input  logic [K_NCHAN-1:0] i_polarity , //!
	//Digital outputs
	output logic               o_boost    , //!
	output logic               o_beep     , //!
	output logic               o_rev      , //!
	output logic               o_brake    , //!
	output logic               o_direction, //!
	// Analog values
	output logic [  K_RES-1:0] o_steer    ,
	output logic [  K_RES-1:0] o_power      //!
);

	localparam K_CHAN_DIRECTION = 0;
	localparam K_CHAN_POWER     = 1;
	localparam K_CHAN_REV       = 2;
	localparam K_CHAN_OTHER     = 3; //! pos = boost, neg = beep


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
				.o_capture_start(                 ),
				.o_capture_done (gen_capture_done ),
				.o_capture_value(gen_capture_value)
			);

			assign capture_done[i]   = gen_capture_done;
			assign analog_values[i]  = signed'(gen_capture_value) - signed'(K_RES'(2**(K_RES-1)));
			assign dead_value        = {1'b0,gen_capture_value[K_RES-2:0]} < i_deadzone;
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
		end else begin
            if (capture_done[K_CHAN_POWER]) begin
                o_power <= analog_values[K_CHAN_POWER];
                o_brake <= i_polarity[K_CHAN_POWER] ? dig_values_neg[K_CHAN_POWER] : dig_values_pos[K_CHAN_POWER];
            end
            if (capture_done[K_CHAN_DIRECTION]) begin
                o_steer <= analog_values[K_CHAN_DIRECTION];
                o_direction <= analog_values[K_CHAN_DIRECTION][K_RES-1] ^ i_polarity[K_CHAN_DIRECTION] ;
            end
            if(capture_done[K_CHAN_REV]) begin
                o_rev <= (~i_polarity[K_CHAN_REV]) ? dig_values_neg[K_CHAN_REV] : dig_values_pos[K_CHAN_REV];
            end
            if(capture_done[K_CHAN_OTHER]) begin
                o_beep      <= (i_polarity[K_CHAN_OTHER]) ? dig_values_neg[K_CHAN_OTHER] : dig_values_pos[K_CHAN_OTHER];;
                o_boost     <= (~i_polarity[K_CHAN_OTHER]) ? dig_values_neg[K_CHAN_OTHER] : dig_values_pos[K_CHAN_OTHER];;
            end
		end
	end

endmodule
