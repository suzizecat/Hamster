module motor_control_top #(parameter K_PWMRES = 10) (
	input  logic                i_clk                     , //! Master clock
	input  logic                i_rst_n                   , //! Master reset
	// Encoder input
	input  logic                i_enc_a                   , //! Encoder A
	input  logic                i_enc_b                   , //! Encoder B
	input  logic                i_enc_i                   , //! Encoder I
	// Commands
	input  logic                i_brake                   ,
	input  logic                i_reverse                 ,
	input  logic [K_PWMRES-1:0] i_pwm_command             , //!Command for the PWM
	input  logic                i_speed_time_base         , //!
	// Parameters
	input  logic                i_param_enc_pol           , //! Encoder reader polarity
	input  logic [         2:0] i_param_i_step            , //! Encoder step for I pulse
	input  logic                i_param_i_step_en         , //! Encoder step will be forced upon I signal
	input  logic [K_PWMRES-1:0] i_param_pwm_max           , //! Maximum PWM Value
	input  logic                i_param_pwr_on_pattern_msb, //!
	input  logic                i_param_pwr_on_pattern_all, //!
	// Outputs
	output logic [         5:0] o_cmd                       //! Output to motor driver
);

	logic       pwm            ;
	logic [5:0] control_pattern;

	// always_comb begin : p_comb_power_mapping
	// 	if (i_param_pwr_on_pattern_msb) begin
	// 		o_cmd = control_pattern;
	// 	end else begin
	// 		o_cmd = {control_pattern[2:0],control_pattern[5:3]} ;
	// 	end
	// end


	logic step_trigger;
	logic step_pol    ;



	pwm_gen_left #(.K_RES(K_PWMRES)) u_pwm_gen (
		.i_clk      (i_clk          ),
		.i_rst_n    (i_rst_n        ),
		.i_enable   (1'b1           ),
		.i_max      (i_param_pwm_max),
		.i_threshold(i_pwm_command  ),
		.o_pwm      (pwm            )
	);

	encoder_reader u_encoder_reader (
		.i_clk     (i_clk          ),
		.i_rst_n   (i_rst_n        ),
		.i_a       (i_enc_a        ),
		.i_b       (i_enc_b        ),
		.i_polarity(i_param_enc_pol),
		.o_step    (step_trigger   ),
		.o_polarity(step_pol       )
	);

	// 15 bits is enough to have 30km/h over 1 sec.
	speed_meter #(.K_WIDTH(15)) u_speed_meter (
		.i_clk         (i_clk            ),
		.i_rst_n       (i_rst_n          ),
		.i_spd_trigger (step_trigger     ),
		.i_time_trigger(i_speed_time_base),
		.i_step_size   (1                ),
		.i_force_reset (0                ),
		.i_unlock      (i_enc_i          ),
		.o_speed       (                 ),
		.o_valid       (                 )
	);


	pattern_generator #(.K_NSUBSTEPS(10)) u_output_stage (
		.i_clk               (i_clk                      ),
		.i_rst_n             (i_rst_n                    ),
		.i_force_step_value  ('b0                        ),
		.i_force_step_trigger('b0                        ),
		.i_force_substep     ('b0                        ),
		.i_step_trigger      (step_trigger               ),
		.i_step_polarity_rev (step_pol                   ),
		.i_step_reverse      (i_reverse                  ),
		.i_brake             (i_brake                    ),
		.i_bypass_power      ('b0                        ),
		.i_cmd_on_lsb        (~i_param_pwr_on_pattern_msb),
		.i_power             (5                          ),
		.o_pattern           (o_cmd                      )
	);

endmodule
