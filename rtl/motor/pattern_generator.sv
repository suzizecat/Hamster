module pattern_generator #(parameter int K_NSUBSTEPS = 10) (
	input  logic                           i_clk               , //! Main clock
	input  logic                           i_rst_n             , //! Reset
	input  logic [                    2:0] i_force_step_value  , //! Step to force
	input  logic                           i_force_step_trigger, //! Trigger step forcing
	input  logic [$clog2(K_NSUBSTEPS)-1:0] i_force_substep     , //!
	input  logic                           i_step_trigger      , //! Trigger next step
	input  logic                           i_step_polarity_rev , //! Select step polarity, 0 is direct
	input  logic                           i_step_reverse      , //! Output the reverse
	input  logic                           i_brake             , //! Brake mode
	input  logic                           i_bypass_power      , //! Force full ON output
	input  logic                           i_cmd_on_lsb        , //! When 1, the commande signals used are patterns LSB
	input  logic [$clog2(K_NSUBSTEPS)-1:0] i_power             , //!
	output logic [                    5:0] o_pattern             //! Motor control pattern
);

	logic [7:0][5:0] step_lut;
	assign step_lut = {
		6'b100010,
		6'b001010,
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

	logic [5:0] selected_output;
	logic [5:0] power_mask     ;
	logic power_on;

	assign substep_increment    = ~step[0] ^ i_step_polarity_rev;
	assign abi_step_cnt_next    = substep_increment ? (abi_step_cnt +1) : (abi_step_cnt -1);
	assign control_step_trigger = i_step_trigger &
		(     substep_increment && 32'(abi_step_cnt) == (K_NSUBSTEPS-1))
		|| (~ substep_increment && abi_step_cnt == 0);

		
	logic [7:0][5:0]  step_next_lut;
	assign step_next_lut = {
	//  { +1 , -1 }  // Step
		{3'd3,3'd1}, // 7
		{3'd1,3'd5}, // 6
		{3'd0,3'd4}, // 5 -- loop
		{3'd5,3'd3}, // 4
		{3'd4,3'd2}, // 3
		{3'd3,3'd1}, // 2
		{3'd2,3'd0}, // 1
		{3'd1,3'd5}  // 0
	};

	assign {step_p1,step_m1} = step_next_lut[step];
	assign step_sel = i_step_reverse ? step_m1 : step_p1;
	
	// always_comb
	// 	begin : p_comb_step
	// 		case (step)
	// 			inside
	// 				0,6 :
	// 					begin
	// 						step_p1 = 1;
	// 						step_m1 = 5;
	// 					end
	// 			[1:4] :
	// 				begin
	// 					step_p1 = step + 1;
	// 					step_m1 = step - 1;
	// 				end
	// 			5 :
	// 				begin
	// 					step_p1 = 0;
	// 					step_m1 = 4;
	// 				end
	// 			7 :
	// 				begin
	// 					step_p1 = 1;
	// 					step_m1 = 0;
	// 				end
	// 			// Default not needed, as all case covered.
	// 		endcase
			
	// 	end

	
	assign selected_output = step_lut[step_sel];
	assign power_mask      = {{3{power_on | i_cmd_on_lsb}},{3{power_on | ~i_cmd_on_lsb}}};

	
	assign power_on = i_bypass_power | (i_power > (i_cmd_on_lsb ? (K_NSUBSTEPS[$clog2(K_NSUBSTEPS)-1:0] -1 - abi_step_cnt ) : abi_step_cnt));

	always_ff @(posedge i_clk or negedge i_rst_n)
		begin : p_seq_substep_counter
			if (~ i_rst_n )
				begin
					abi_step_cnt <= $size(abi_step_cnt)'(0);
					step         <= 5;
					o_pattern    <= 0;
				end
			else
				begin
					o_pattern <= i_brake ? 6'b000111 : (selected_output & power_mask);
					if (i_force_step_trigger)
						begin
							step         <= (i_force_step_value < 6) ? i_force_step_value : 0;
							abi_step_cnt <= i_force_substep;
						end
					else
						begin
							if(i_step_trigger)
								begin
									if (control_step_trigger)
										begin
											step <= i_step_polarity_rev ? step_m1 : step_p1;
										end
									else
										begin
											abi_step_cnt <= abi_step_cnt_next;
										end
								end
						end
				end
		end


endmodule
