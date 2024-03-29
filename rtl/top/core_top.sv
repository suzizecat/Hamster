`include "debug.svh"
`include "decoder.svh"
//
module core_top (
	input  logic        i_clk          , //! Main clock
	input  logic        i_rst_n        , //! Main reset
	//Encoder inputs
	input  logic        i_enc1_a       , //! Encoder 1 A
	input  logic        i_enc1_b       , //! Encoder 1 B
	input  logic        i_enc1_i       , //! Encoder 1 I
	input  logic        i_enc2_a       , //! Encoder 2 A
	input  logic        i_enc2_b       , //! Encoder 2 B
	input  logic        i_enc2_i       , //! Encoder 2 I
	input logic  i_enc1_pos_pwm, //! 
	input logic  i_enc2_pos_pwm, //! 
	
	// Commands
	input  logic [3:0]  i_channels     , //! Brake command
	//Motors interfaces
	output logic [5:0]  o_cmd_m1       ,
	output logic [5:0]  o_cmd_m2       ,
	// SPI interface
	input  logic        i_cs_n         , //!
	input  logic        i_mosi         , //!
	input  logic        i_spi_clk      , //!
	output logic        o_miso         , //!
	// Debug outputs
	output spi_events_t dbg_spi        ,
	output logic        o_rb_read_valid, //!
	output logic        o_rb_read_req  , //!
	output logic        o_rb_write_req   //!
);

	localparam int PWM_RES    = 8 ;
	localparam int REG_DWIDTH = 16;
	localparam int REG_AWIDTH = 8 ;
	localparam int K_NCHAN    = 4 ;

	hamster_regbank_out_if regbank_out ();

	hamster_regbank_in_if regbank_in ();

	reg_wrchan_if #(
		.K_DWIDTH(REG_DWIDTH),
		.K_AWIDTH(REG_AWIDTH)
	) spi_rb_wr ();

	reg_rdchan_if #(
		.K_DWIDTH(REG_DWIDTH),
		.K_AWIDTH(REG_AWIDTH)
	) spi_rb_rd ();

	logic [K_NCHAN-1:0][$clog2(K_NCHAN)-1:0] radio_route    ;
	logic [K_NCHAN-1:0][        PWM_RES-1:0] radio_deadzones;
	logic [K_NCHAN-1:0]                      radio_pol      ;

	logic [15:0] spi_miso_data ;
	logic [15:0] spi_mosi_data ;
	logic        spi_miso_valid;
	logic        spi_rxne      ;
	logic        spi_txe       ;
	logic        spi_selected  ;

	logic               cmd_boost    ;
	logic               cmd_beep     ;
	logic               cmd_rev      ;
	logic               cmd_brake    ;
	logic               cmd_direction;
	logic [PWM_RES-1:0] cmd_steer    ;
	logic [PWM_RES-1:0] cmd_power    ;

	logic [PWM_RES-1:0] rescaled_cmd_power;

	logic cmd_power_done;

	logic time_speed;

	decoded_cmd_t spi_command;

	assign dbg_spi.selected = spi_selected;
	assign dbg_spi.rx_evt   = spi_rxne;
	assign dbg_spi.txe      = spi_txe;
	assign dbg_spi.rx_data  = spi_mosi_data;


	assign radio_deadzones = {
		PWM_RES'(regbank_out.RADIO1DEAD_VAL),
		PWM_RES'(regbank_out.RADIO2DEAD_VAL),
		PWM_RES'(regbank_out.RADIO3DEAD_VAL),
		PWM_RES'(regbank_out.RADIO4DEAD_VAL)
	};

	assign radio_route = {
		regbank_out.RADIOCFGR_OTHER_CHAN,
		regbank_out.RADIOCFGR_REV_CHAN,
		regbank_out.RADIOCFGR_PWR_CHAN,
		regbank_out.RADIOCFGR_DIR_CHAN
	};

	assign radio_pol = {
		regbank_out.RADIOPOL_DIR_POL,
		regbank_out.RADIOPOL_PWR_POL,
		regbank_out.RADIOPOL_REV_POL,
		regbank_out.RADIOPOL_OTHER_POL
	};

	spi_slave #(.K_DWIDTH(16)) u_spi_slave (
		.i_clk          (i_clk         ),
		.i_rst_n        (i_rst_n       ),
		.i_data_to_send (spi_miso_data ),
		.i_valid_data   (spi_miso_valid),
		.o_data_recieved(spi_mosi_data ),
		.o_rx_event     (spi_rxne      ),
		.o_txe          (spi_txe       ),
		.o_selected     (spi_selected  ),
		.i_cpol         (1'b0          ),
		.i_cpha         (1'b0          ),
		.i_mosi         (i_mosi        ),
		.i_spi_clk      (i_spi_clk     ),
		.i_cs_n         (i_cs_n        ),
		.o_miso         (o_miso        ),
		.o_dbg_mosi_cnt (dbg_spi.tx_cnt),
		.o_dbg_miso_cnt (dbg_spi.rx_cnt),
		.dgb_clk_rise   (dbg_spi.clk_r ),
		.dbg_clk_fall   (dbg_spi.clk_f )
	);

	cmd_decoder u_cmd_decode (
		.i_clk      (i_clk        ),
		.i_rst_n    (i_rst_n      ),
		.i_spi_csn  (i_cs_n       ),
		.i_spi_data (spi_mosi_data),
		.i_spi_valid(spi_rxne     ),
		.o_command  (spi_command  )
	);

	spi_rb_interface u_spi_rb_interface (
		.i_clk             (i_clk             ),
		.i_rst_n           (i_rst_n           ),
		.mif_wr_rb         (spi_rb_wr         ),
		.mif_rd_rb         (spi_rb_rd         ),
		.i_spi_request_data(spi_rxne),
		.i_spi_rx_data     (spi_mosi_data     ),
		.o_spi_tx_data     (spi_miso_data     ),
		.o_spi_tx_valid    (spi_miso_valid    ),
		.i_command         (spi_command         )
	);


	// spi_rb_interface u_spi_rb_interface (
	// 	.i_clk         (i_clk         ),
	// 	.i_rst_n       (i_rst_n       ),
	// 	.mif_wr_rb     (spi_rb_wr     ),
	// 	.mif_rd_rb     (spi_rb_rd     ),
	// 	.i_spi_in_data (spi_mosi_data ),
	// 	.o_spi_out_data(spi_miso_data ),
	// 	.i_spi_rx      (spi_rxne      ),
	// 	.i_spi_txe     (spi_txe       ),
	// 	.i_csn         (~spi_selected ),
	// 	.o_spi_valid_tx(spi_miso_valid)
	// );

	assign o_rb_write_req  = spi_rb_wr.write;
	assign o_rb_read_valid = spi_rb_rd.valid;
	assign o_rb_read_req   = spi_rb_rd.read;

	assign regbank_in.COMPID_COMP_ID     = 16'hA001;
	assign regbank_in.COMPTEST_COMP_TEST = 16'hCAFE;


	hamster_regbank u_regbank (
		.i_clk          (i_clk      ),
		.i_rst_n        (i_rst_n    ),
		.sif_reg_wrchan (spi_rb_wr  ),
		.sif_reg_rdchan (spi_rb_rd  ),
		.sif_regbank_in (regbank_in ),
		.mif_regbank_out(regbank_out)
	);

	timebase #(.K_RES(14)) u_speed_timebase (
		.i_clk  (i_clk     ),
		.i_rst_n(i_rst_n   ),
		.i_stop (1'b0      ),
		.i_thr  (14'd10000 ),
		.o_tick (time_speed)
	);

	channels_decoder #(
		.K_NCHAN(4      ),
		.K_RES  (PWM_RES)
	) u_channel_decode (
		.i_clk           (i_clk                                 ),
		.i_rst_n         (i_rst_n                               ),
		.i_chan_route    (radio_route                           ),
		.i_channels      (i_channels                            ),
		.i_deadzone      (radio_deadzones[0]                    ),
		.i_skip_threshold(regbank_out.RADIOSKIP_VAL[PWM_RES-1:0]),
		.i_timebase      (1'b1                                  ),
		.i_polarity      (radio_pol                             ),
		.o_boost         (cmd_boost                             ),
		.o_beep          (cmd_beep                              ),
		.o_rev           (cmd_rev                               ),
		.o_brake         (cmd_brake                             ),
		.o_direction     (cmd_direction                         ),
		.o_steer         (cmd_steer                             ),
		.o_power         (cmd_power                             ),
		.o_power_done    (cmd_power_done                        )
	);

	div #(
		.WIDTH(PWM_RES),
		.FBITS(0      )
	) u_div_power (
		.i_clk  (i_clk                                   ),
		.i_rst_n(i_rst_n                                 ),
		.i_start(cmd_power_done                          ),
		.o_busy (                                        ),
		.o_valid(                                        ),
		.o_dbz  (                                        ),
		.o_ovf  (                                        ),
		.i_x    (cmd_power                               ),
		.i_y    (regbank_out.RADIOPWRDIV_DIV[PWM_RES-1:0]),
		.o_q    (rescaled_cmd_power                      ),
		.o_r    (                                        )
	);

// 	encoder_pwm_read #(
//     .K_DWIDTH          (20),
//     .K_NSTEP_PERIOD    (400)
// ) u_encoder_pwm_read (
//     .i_clk             (i_clk),
//     //! System clock
// 	    .i_rst_n           (i_rst_n),
//     //! System reset
// 	    .i_pwm             (i_pwm),
//     //! Input PWM
// 	    .i_start           (i_start),
//     //! Trigger
// 	    .i_clear           (i_clear),
//     //! Clear result
// 	    .o_enc_pos         (o_enc_pos),
//     //! Output result
// 	    .o_cal_factor      (o_cal_factor),
//     //! Result is valid
//     .o_valid           (o_valid)
// );

	motor_control_top #(.K_PWMRES(PWM_RES)) u_mot_1 (
		.i_clk                     (i_clk                               ),
		.i_rst_n                   (i_rst_n                             ),
		.i_enc_a                   (i_enc1_a                            ),
		.i_enc_b                   (i_enc1_b                            ),
		.i_enc_i                   (i_enc1_i                            ),
		.i_brake                   (cmd_brake                           ),
		.i_reverse                 (cmd_rev                             ),
		.i_pwr_command             (rescaled_cmd_power[3:0]             ),
		.i_pwm_command             (cmd_power                           ),
		.i_speed_time_base         (time_speed                          ),
		.i_param_enc_pol           (regbank_out.MOT1CR_ENC_POL          ),
		.i_param_i_step            (regbank_out.MOT1CR_I_STEP           ),
		.i_param_i_step_en         (regbank_out.MOT1CR_I_EN             ),
		.i_param_pwm_max           (regbank_out.MOT1PWM_MAX[PWM_RES-1:0]),
		.i_param_pwr_on_pattern_msb(regbank_out.MOT1CR_PWR_MSB          ),
		.i_param_pwr_on_pattern_all(regbank_out.MOT1CR_PWR_ALL          ),
		.i_param_low_speed_thr     (regbank_out.SPDLOW_SPDLOWTHR        ),
		.o_cmd                     (o_cmd_m1                            )
	);

	motor_control_top #(.K_PWMRES(PWM_RES)) u_mot_2 (
		.i_clk                     (i_clk                               ),
		.i_rst_n                   (i_rst_n                             ),
		.i_enc_a                   (i_enc2_a                            ),
		.i_enc_b                   (i_enc2_b                            ),
		.i_enc_i                   (i_enc2_i                            ),
		.i_brake                   (cmd_brake                           ),
		.i_reverse                 (cmd_rev                             ),
		.i_pwr_command             (rescaled_cmd_power[3:0]             ),
		.i_pwm_command             (cmd_power                           ),
		.i_speed_time_base         (time_speed                          ),
		.i_param_enc_pol           (regbank_out.MOT2CR_ENC_POL          ),
		.i_param_i_step            (regbank_out.MOT2CR_I_STEP           ),
		.i_param_i_step_en         (regbank_out.MOT2CR_I_EN             ),
		.i_param_pwm_max           (regbank_out.MOT2PWM_MAX[PWM_RES-1:0]),
		.i_param_pwr_on_pattern_msb(regbank_out.MOT2CR_PWR_MSB          ),
		.i_param_pwr_on_pattern_all(regbank_out.MOT2CR_PWR_ALL          ),
		.i_param_low_speed_thr     (regbank_out.SPDLOW_SPDLOWTHR        ),
		.o_cmd                     (o_cmd_m2                            )
	);


endmodule
