module pattern_generator #(parameter int K_NSUBSTEPS = 10) (
	input  logic                           i_clk               , //! Main clock
	input  logic                           i_rst_n             , //! Reset
	input  logic [                    2:0] i_force_step_value  , //! Step to force
	input  logic                           i_force_step_trigger, //! Trigger step forcing
	input  logic                           i_step_trigger      , //! Trigger next step
	input  logic                           i_step_polarity_rev , //! Select step polarity, 0 is direct
	input  logic                           i_step_reverse      , //! Output the reverse
	input  logic                           i_brake             , //! Brake mode
	input  logic [$clog2(K_NSUBSTEPS)-1:0] i_power             , //!
	output logic [                    5:0] o_pattern           , //! Motor control pattern
	output logic [$clog2(K_NSUBSTEPS)-1:0] o_substep
);

	logic [5:0][5:0] step_lut;
	assign step_lut = {
		6'b001100,
		6'b010100,
		6'b010001,
		6'b100001,
		6'b100010,
		6'b001010
	};

	logic [2:0] step    ;
	logic [2:0] step_p1 ;
	logic [2:0] step_m1 ;
	logic [2:0] step_sel;

	logic [$clog2(K_NSUBSTEPS)-1:0] abi_step_cnt     ;
	logic [$clog2(K_NSUBSTEPS)-1:0] abi_step_cnt_next;

	logic substep_increment   ;
	logic control_step_trigger;

	assign substep_increment    = ~step[0] ^ i_step_polarity_rev;
	assign abi_step_cnt_next    = substep_increment ? (abi_step_cnt +1) : (abi_step_cnt -1);
	assign control_step_trigger = i_step_trigger &
		(     substep_increment && 32'(abi_step_cnt) == (K_NSUBSTEPS-1))
		|| (~ substep_increment && abi_step_cnt == 0);


	always_comb begin : p_comb_step
		case (step)
			0 : begin
				step_p1 = 1;
				step_m1 = 5;
			end
			5 : begin
				step_p1 = 0;
				step_m1 = 4;
			end
			default : begin
				step_p1 = step + 1;
				step_m1 = step - 1;
			end
		endcase

		step_sel = i_step_reverse ? step_m1 : step_p1;
	end

logic [5:0] selected_output;
logic [5:0] power_mask;

assign selected_output = step_lut[step_sel];
assign power_mask = {{3{power_on}},3'b111};

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_substep_counter
		if (~ i_rst_n ) begin
			abi_step_cnt <= $size(abi_step_cnt)'(K_NSUBSTEPS-1);
			step         <= 0;
			o_pattern    <= 0;
		end else begin
			o_pattern    <= i_brake ? 6'b000111 : (selected_output & power_mask);
			if(i_step_trigger) begin
				if (control_step_trigger) begin
					step         <= i_step_polarity_rev ? step_m1 : step_p1;
				end else begin
					abi_step_cnt <= abi_step_cnt_next;
				end
			end
		end
	end

	logic power_on;
	assign power_on = i_power > abi_step_cnt;

endmodule
