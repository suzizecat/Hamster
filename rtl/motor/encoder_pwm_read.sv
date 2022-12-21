module encoder_pwm_read #(parameter int K_DWIDTH = 20,
parameter int K_NSTEP_PERIOD = 400)(
	input  logic        		i_clk    , //! System clock
	input  logic        		i_rst_n  , //! System reset
	input  logic        		i_pwm    , //! Input PWM
	input  logic        		i_start  , //! Trigger
	input  logic        		i_clear  , //! Clear result
	output logic [11:0] 		o_enc_pos, //! Output result
	output logic [K_DWIDTH-1:0] o_cal_factor,
	output logic                o_valid    //! Result is valid
);

	typedef enum logic[4:0] { IDLE, CALIBRATING, ACQUIRING, DONE } fsm_state_t;

	fsm_state_t state     ;
	fsm_state_t state_next;

	logic calibration_done;
	logic acquisition_done;

	logic [K_DWIDTH-1:0] counter;

	logic last_pwm       ;
	logic pwm_rising_edge;
	logic pwm_falling_edge;

	logic acquisition_ongoing;


	logic div_done;
	logic [K_DWIDTH -1 :0] div_result;


	always_comb begin : p_comb_fsm
		state_next = state;
		case (state)
			IDLE : begin
				if(i_start | i_clear) begin
					state_next = CALIBRATING;
				end
			end
			CALIBRATING : begin
				if (calibration_done) begin
					state_next = ACQUIRING;
				end
			end
			ACQUIRING : begin
				if(acquisition_done) begin
					state_next = DONE;
				end
			end
			DONE : begin
				if(i_clear) begin
					state_next = CALIBRATING;
				end else if (i_start) begin
					state_next = ACQUIRING;
				end
			end
			default : state_next = IDLE;
		endcase
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_fsm
		if (~ i_rst_n ) begin
			state <= IDLE;
		end else begin
			state <= state_next;
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_signaling_edge
		if (~ i_rst_n ) begin
			last_pwm        <= 0;
			pwm_rising_edge <= 0;
			pwm_falling_edge <=0;
		end else begin
			last_pwm        <= i_pwm;
			pwm_rising_edge <= i_pwm & ~last_pwm;
			pwm_falling_edge<= ~i_pwm & last_pwm;

		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_cal_counter
		if (~ i_rst_n ) begin
			counter <= 0;
			acquisition_ongoing <= 0;
			acquisition_done <= 0;
		end else begin
			acquisition_done <= 0;
			if(state == CALIBRATING) begin
				if(pwm_rising_edge) begin
					if (~acquisition_ongoing) begin
						counter <= 0;
						acquisition_ongoing <= 1;
					end else begin
						acquisition_done <= 1;
						acquisition_ongoing <= 0;
					end
				end else begin
						counter <= counter +1;
				end
			end else if (state == ACQUIRING) begin
				if(pwm_rising_edge) begin
					counter <= 0;
					acquisition_ongoing <= 1;
				end else if (acquisition_ongoing & pwm_falling_edge) begin
					acquisition_done <= 1;
					acquisition_ongoing <= 0;
				end else if (acquisition_ongoing) begin
						counter <= counter +1;
				end 
			end else begin
					counter <= 0;
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_div_done
		if (~ i_rst_n ) begin
			calibration_done <= 0;
			o_enc_pos <= 0;
			o_valid <= 0;
		end else begin
			calibration_done <= 0;
			o_valid <= 0;
			if (div_done == 1'b1) begin
				if (state == CALIBRATING) begin
					o_cal_factor <= div_result;
					calibration_done <= 1;
				end else begin
					o_enc_pos <= div_result[$left(o_enc_pos):0];
					o_valid <= 1;
				end
			end
		end
	end

	div #(
		.WIDTH      (K_DWIDTH), // width of numbers in bits
		.FBITS      (0			 )	// fractional bits (for fixed point)
	) u_div (
		.i_clk      (i_clk),
		.i_rst_n    (i_rst_n),
		.i_start    (acquisition_done),// i_start signal  
		.o_busy     (),// calculation in progress
		.o_valid    (div_done),// quotient and remainder are o_valid
		.o_dbz      (		 ),// divide by zero flag
		.o_ovf      (		 ),// overflow flag (fixed-point)
		.i_x        (counter ),// dividend
		.i_y        (state == CALIBRATING ? K_DWIDTH'(K_NSTEP_PERIOD) : o_cal_factor),// divisor
		.o_q        (div_result),// quotient    
		.o_r        ()// remainder
	);

endmodule
