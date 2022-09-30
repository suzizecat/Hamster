module encoder_pwm_read (
	input  logic        i_clk    , //! System clock
	input  logic        i_rst_n  , //! System reset
	input  logic        i_pwm    , //! Input PWM
	input  logic        i_start  , //! Trigger
	input  logic        i_clear  , //! Clear result
	output logic [11:0] o_enc_pos, //! Output result
	output logic        o_valid    //! Result is valid
);

	typedef enum logic[4:0] { IDLE, CALIBRATING, ACQUIRING, DONE } fsm_state_t;

	fsm_state_t state     ;
	fsm_state_t state_next;

    logic calibration_done;
    logic acquisition_done;

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

endmodule
