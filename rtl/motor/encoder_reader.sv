module encoder_reader (
	input  logic i_clk     , //! Master clock
	input  logic i_rst_n   , //! Reset
	// Encoder interface
	input  logic i_a       , //! A input of encoder
	input  logic i_b       , //! B input of encoder
	input  logic i_polarity, //! Output polarity
	// Output stage
	output logic o_step    , //! Signal that a step  was done
	output logic o_polarity  //! Triggered step polarity
);

	logic [1:0] previous_ab;
	logic [1:0] current_ab ;

	assign current_ab = {i_a,i_b};


	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_encoder_reader
		if (~ i_rst_n ) begin
			o_step      <= 0;
			o_polarity  <= 0;
			previous_ab <= 0;
		end else begin
			previous_ab <= current_ab;
			o_step      <= 0;
			o_polarity  <= 0;
			if (current_ab == ((previous_ab) ^ 2'b10)) begin
				o_step     <= 1;
				o_polarity <= i_polarity;
			end
			if (current_ab == ((previous_ab) ^ 2'b01)) begin
				o_step     <= 1;
				o_polarity <= ~i_polarity;
			end
		end
	end
endmodule
