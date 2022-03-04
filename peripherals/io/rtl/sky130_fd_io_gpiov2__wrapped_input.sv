module sky130_fd_io_gpiov2__wrapped_input (
	input  logic i_io_pad  , //!
	output logic o_todesign
);

	wire logic vdd  ;
	wire logic vss  ;
	wire logic vddio;
	wire logic vssio;
	wire logic vssa;
	wire logic vdda;

	wire logic tie_hi;
	wire logic tie_low;

	sky130_fd_io__top_gpiov2 u_gpio (
		.IN_H            (          ),
		.PAD_A_NOESD_H   (          ),
		.PAD_A_ESD_0_H   (          ),
		.PAD_A_ESD_1_H   (          ),
		.PAD             (i_pad     ),
		.DM              (3'b110    ),
		.HLD_H_N         (          ),
		.IN              (o_todesign),
		.INP_DIS         (          ),
		.IB_MODE_SEL     (1'b0      ),
		.ENABLE_H        (          ),
		.ENABLE_VDDA_H   (vdda      ),
		.ENABLE_INP_H    (tie_low   ),
		.OE_N            (1'b0      ),
		.TIE_HI_ESD      (tie_hi    ),
		.TIE_LO_ESD      (tie_low   ),
		.SLOW            (1'b1      ),
		.VTRIP_SEL       (1'b0      ),
		.HLD_OVR         (          ),
		.ANALOG_EN       (1'b0      ),
		.ANALOG_SEL      (1'b0      ),
		.ENABLE_VDDIO    (          ),
		.ENABLE_VSWITCH_H(          ),
		.ANALOG_POL      (1'b0      ),
		.OUT             (1'b0      ),
		.AMUXBUS_A       (vssa      ),
		.AMUXBUS_B       (vssa      ),
		
		.VSSA            (vssio     ),
		.VDDA            (vddio     ),
		.VSWITCH         (          ),
		.VDDIO_Q         (vddio     ),
		.VCCHIB          (vcc       ),
		.VDDIO           (vddio     ),
		.VCCD            (vcc       ),
		.VSSIO           (vssio     ),
		.VSSD            (vss       ),
		.VSSIO_Q         (vssio     )
	);

endmodule
