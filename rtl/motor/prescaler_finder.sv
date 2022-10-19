module prescaler_finder #(
	parameter int K_PERIODWIDTH = 13,
	parameter int K_PRESCWIDTH  = 7
) (
	input  logic                     i_clk            , //!
	input  logic                     i_rst_n          , //!
	input  logic                     i_reference_event, //!
	input  logic                     i_start          , //!
	input  logic [K_PERIODWIDTH-1:0] i_period_target  , //!
	output logic [ K_PRESCWIDTH-1:0] o_prescaler      , //!
	output logic                     o_done           , //!
	output logic                     o_ongoing          //!
);

	logic [$clog2(K_PRESCWIDTH)-1:0] pos       ;
	logic [       K_PERIODWIDTH-1:0] period_cnt;

	logic prescaled_tick;
	logic is_done       ;

	timebase #(.K_RES(K_PERIODWIDTH)) timebase_dut (
		.i_clk  (i_clk                         ),
		.i_rst_n(i_rst_n                       ),
		.i_stop (~o_ongoing | i_reference_event),
		.i_thr  (K_PERIODWIDTH'(o_prescaler)   ),
		.o_tick (prescaled_tick                )
	);

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_signaling
		if (~ i_rst_n ) begin
			o_done    <= 0;
			o_ongoing <= 0;
		end else begin
			o_done <= 0;
			if(i_start) begin
				o_ongoing <= 1;
			end else if (is_done) begin
				o_done    <= 1;
				o_ongoing <= 0;
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_cnt
		if (~ i_rst_n ) begin
			period_cnt <= 0;
		end else begin
			if(i_reference_event) begin
				period_cnt <= 0;
			end else begin
				if(prescaled_tick) begin
					period_cnt <= period_cnt +1;
				end
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_process
		if (~ i_rst_n ) begin
			pos         <= $size(pos)'(K_PRESCWIDTH-1);
			o_prescaler <= {1'b1,{(K_PRESCWIDTH-1){1'b0}}};
			is_done     <= 0;
		end else begin
			is_done <= 0;
			if(i_start) begin
				o_prescaler <= {1'b1,{(K_PRESCWIDTH-1){1'b0}}};
				pos         <= $size(pos)'(K_PRESCWIDTH-1);
			end else begin
				if(o_ongoing & i_reference_event) begin

					if(period_cnt < i_period_target) begin
						o_prescaler[pos] <= 0;
					end

					if (pos != 0) begin
						pos                <= pos -1;
						o_prescaler[pos-1] <= 1;
					end else begin
						is_done <= 1;
					end
				end
			end
		end
	end



endmodule
