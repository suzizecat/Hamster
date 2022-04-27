module pattern_generator (
	input  logic       i_clk               , //! Main clock
	input  logic       i_rst_n             , //! Reset
	input  logic [2:0] i_force_step_value  , //! Step to force
	input  logic       i_force_step_trigger, //! Trigger step forcing
	input  logic       i_step_trigger      , //! Trigger next step
	input  logic       i_step_polarity     , //! Select step polarity
	input  logic       i_step_reverse      , //! Output the reverse
	input  logic       i_brake             , //! Brake mode
	output logic [5:0] o_pattern             //! Motor control pattern
);

	logic [5:0][5:0] step_lut;
	assign step_lut = {
		6'b100001,
		6'b100010,
		6'b001010,
		6'b001100,
		6'b010100,
		6'b010001
	};

	logic [2:0] step    ;
	logic [2:0] step_p1 ;
	logic [2:0] step_m1 ;
	logic [2:0] step_sel;


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


	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_step
		if (~ i_rst_n ) begin
			step      <= 0;
			o_pattern <= 0;
		end else begin
			if(i_step_trigger ) begin
				step      <= i_step_polarity ? step_p1 : step_m1;
				o_pattern <= i_brake ? 6'b000111 : step_lut[step_sel];
			end
			if (i_force_step_trigger) begin
				step <= i_force_step_value;
			end

		end
	end
endmodule
