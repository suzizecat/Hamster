module motor_control_top #(parameter K_PWMRES = 10) (
	input  logic        i_clk                     , //! Master clock
	input  logic        i_rst_n                   , //! Master reset
	// Encoder input
	input  logic        i_enc_a                   , //! Encoder A
	input  logic        i_enc_b                   , //! Encoder B
	input  logic        i_enc_i                   , //! Encoder I
	// Commands
	input  logic        i_brake                   ,
	input  logic        i_reverse                 ,
	input  logic [K_PWMRES-1:0] i_pwm_command             , //!Command for the PWM
	// Parameters
	input  logic        i_param_enc_pol           , //! Encoder reader polarity
	input  logic [ 2:0] i_param_i_step            , //! Encoder step for I pulse
	input  logic        i_param_i_step_en         , //! Encoder step will be forced upon I signal
	input  logic [K_PWMRES-1:0] i_param_pwm_max           , //! Maximum PWM Value
	input  logic        i_param_pwr_on_pattern_msb, //!
	input  logic        i_param_pwr_on_pattern_all, //!
	// Outputs
	output logic [ 5:0] o_cmd                       //! Output to motor driver
);

	logic       pwm            ;
	logic [5:0] control_pattern;

	always_comb begin : p_comb_power_mapping
		if (i_param_pwr_on_pattern_msb) begin
			o_cmd = control_pattern & {{3{pwm}},3'b111};
		end else begin
			o_cmd = control_pattern & {3'b111, {3{pwm}}};
		end
	end


	logic step_trigger;
	logic step_pol    ;



	pwm_gen_left #(.K_RES(K_PWMRES)) pwm_gen_left_dut (
		.i_clk      (i_clk          ),
		.i_rst_n    (i_rst_n        ),
		.i_enable   (1'b1           ),
		.i_max      (i_param_pwm_max),
		.i_threshold(i_pwm_command  ),
		.o_pwm      (pwm            )
	);

	encoder_reader encoder_reader_dut (
		.i_clk     (i_clk          ),
		.i_rst_n   (i_rst_n        ),
		.i_a       (i_enc_a        ),
		.i_b       (i_enc_b        ),
		.i_polarity(i_param_enc_pol),
		.o_step    (step_trigger   ),
		.o_polarity(step_pol       )
	);

	pattern_generator pattern_generator_dut (
		.i_clk               (i_clk                      ),
		.i_rst_n             (i_rst_n                    ),
		.i_force_step_value  (i_param_i_step             ),
		.i_force_step_trigger(i_param_i_step_en & i_enc_i),
		.i_step_trigger      (step_trigger               ),
		.i_step_polarity     (step_pol                   ),
		.i_step_reverse      (i_reverse                  ),
		.i_brake             (i_brake                    ),
		.o_pattern           (control_pattern            )
	);


endmodule
