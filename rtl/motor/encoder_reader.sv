module encoder_reader (
	input  logic i_clk       , //! Master clock
	input  logic i_rst_n     , //! Reset
	// Encoder interface
	input  logic i_a         , //! A input of encoder
	input  logic i_b         , //! B input of encoder
	input  logic i_polarity  , //! Output polarity
	// Output stage
	output logic o_step      , //! Signal that a step  was done
	output logic o_polarity  , //! Triggered step polarity
	output logic o_dir_change  //! Pulse when polarity change
);

	logic [1:0] expected_ab_pos;
	logic [1:0] expected_ab_neg;
	logic [1:0] current_ab     ;

	const logic [3:0][1:0] positive_abi_lut = {
		2'b01, // 11 -> 01
		2'b11, // 10 -> 11
		2'b00, // 01 -> 00
		2'b10  // 00 -> 10
	};

	const logic [3:0][1:0] negative_abi_lut = {
		2'b10, // 11 -> 10
		2'b00, // 10 -> 00
		2'b11, // 01 -> 11
		2'b01  // 00 -> 01
	};

	assign current_ab = {i_a,i_b};


	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_encoder_reader
		if (~ i_rst_n ) begin
			o_step          <= 0;
			o_polarity      <= 0;
			expected_ab_pos <= 0;
			expected_ab_neg <= 0;
			o_dir_change    <= 0;
		end else begin
			expected_ab_pos <= positive_abi_lut[current_ab];
			expected_ab_neg <= negative_abi_lut[current_ab];
			o_step          <= 0;
			//o_polarity      <= 0;

			if (current_ab == expected_ab_pos) begin
				o_step       <= 1;
				o_polarity   <= i_polarity;
				o_dir_change <= o_polarity ^ (i_polarity);
			end
			if (current_ab == expected_ab_neg) begin
				o_step       <= 1;
				o_polarity   <= ~i_polarity;
				o_dir_change <= o_polarity ^ (~i_polarity);
			end
		end
	end
endmodule
