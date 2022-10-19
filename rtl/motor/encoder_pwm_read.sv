module encoder_pwm_read (
	input  logic        i_clk    , //! System clock
	input  logic        i_rst_n  , //! System reset
	input  logic        i_pwm    , //! Input PWM
	input  logic        i_start  , //! Trigger
	input  logic        i_clear  , //! Clear result
	output logic [11:0] o_enc_pos, //! Output result
	output logic        o_valid    //! Result is valid
);

	localparam int K_CAL_DWIDTH = 16;

	typedef enum logic[4:0] { IDLE, CALIBRATING, ACQUIRING, DONE } fsm_state_t;

	fsm_state_t state     ;
	fsm_state_t state_next;

	logic calibration_done;
	logic acquisition_done;

	logic [K_CAL_DWIDTH-1:0] cal_counter;
	logic [K_CAL_DWIDTH-1:0] ref_counter;

	logic [$clog2(K_CAL_DWIDTH)-1:0] cal_pos;

	logic last_pwm       ;
	logic pwm_rising_edge;


	always_comb begin : p_comb_fsm
		state_next = state;
		case (state)
			IDLE : begin
				if(i_start) begin
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
		end else begin
			last_pwm        <= i_pwm;
			pwm_rising_edge <= i_pwm & ~last_pwm;

		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_cal_counter
		if (~ i_rst_n ) begin
			cal_counter <= 0;
		end else begin
			if(state == CALIBRATING) begin
				if(pwm_rising_edge) begin
					cal_counter <= 0;
				end else begin
					cal_counter <= cal_counter +1;
				end
			end else begin
				cal_counter <= 0;
			end
		end
	end

	logic cal_started;

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_calibration
		if (~ i_rst_n ) begin
			cal_pos     <= K_CAL_DWIDTH-1;
			ref_counter <= {1'b1,{(K_CAL_DWIDTH-1){1'b0}}};
			cal_started <= 0;
		end else begin
			if (state == CALIBRATING) begin
				if(pwm_rising_edge) begin
					cal_started <= 1;
					if(cal_started) begin
						if(ref_counter == cal_counter) begin
							calibration_done <= 1;
						end
					end
				end
			end

		end
	end


div #(
    .WIDTH      (4),    // width of numbers in bits
    
    .FBITS      (0)// fractional bits (for fixed point)
) u_div (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_start    (i_start),// i_start signal  
    .o_busy     (o_busy),// calculation in progress
    .o_valid    (o_valid),// quotient and remainder are o_valid
    .o_dbz      (o_dbz),// divide by zero flag
    .o_ovf      (o_ovf),// overflow flag (fixed-point)
    .i_x        (i_x),// dividend
    .i_y        (i_y),// divisor
    .o_q        (o_q),// quotient    
    .o_r        (o_r)// remainder
);

endmodule
