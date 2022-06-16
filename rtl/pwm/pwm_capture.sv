module pwm_capture #(parameter K_DWIDTH = 16) (
	input  logic                i_clk          , //! High-speed clock
	input  logic                i_rst_n        , //! Master reset
	input  logic                i_timebase     , //! Input counting pulse
	input  logic                i_pwm          , //! PWM to be measured
	input  logic                i_polarity     , //! PWM edge to start triggering on. 0 = rising edge
	input  logic [K_DWIDTH-1:0] i_skip         , //! Skip the first n clock cycles
	output logic                o_capture_start, //! Sync pulse of capture start
	output logic                o_capture_done , //! Signal that a capture is done and data is ready
	output logic [K_DWIDTH-1:0] o_capture_value  //! Captured value
);

	typedef enum logic[1:0] {WAITING, SKIPPING, COUNTING } capture_state_t;

	capture_state_t       fsm_state     ;
	capture_state_t       fsm_state_next;

	capture_state_t [1:0] transition    ;
	assign transition = {fsm_state,fsm_state_next};

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_fsm_next
		if (~ i_rst_n ) begin
			fsm_state <= WAITING;
		end else begin
			o_capture_start <= 0;
			o_capture_done  <= transition == {COUNTING,WAITING} & i_timebase;
			if (i_timebase) begin
				fsm_state <= fsm_state_next;
				if (transition == {SKIPPING,COUNTING}) begin
					o_capture_value <= 0;
					o_capture_start <= 1;
				end
				if (transition == {COUNTING,COUNTING}) begin
					if(~(&o_capture_value)) begin
						o_capture_value <= o_capture_value +1;	
					end
				end
				if (transition == {SKIPPING,SKIPPING}) begin
					o_capture_value <= o_capture_value +1;
				end
			end

		end
	end

	always_comb begin : p_comb_fsm
		fsm_state_next = fsm_state;
		case (fsm_state)
			WAITING :
				begin
					if (i_pwm ^ i_polarity) begin
						fsm_state_next = SKIPPING;
					end
				end
			SKIPPING :
				begin
					if (~i_pwm ^ i_polarity) begin
						fsm_state_next = WAITING;
					end else if ((&o_capture_value) | o_capture_value == i_skip) begin
						fsm_state_next = COUNTING;
					end
				end
			COUNTING :
				begin
					if (~i_pwm ^ i_polarity) begin
						fsm_state_next = WAITING;
					end
				end
			default :
				begin
					fsm_state_next = WAITING;
				end
		endcase
	end

endmodule
