module speed_loop #(
	parameter int K_BUFWIDTH = 13,
	parameter int K_CMDWIDTH = 12
) (
	input  logic                  i_clk          , //!
	input  logic                  i_rst_n        , //!
	input  logic                  i_next_step    , //!
	input  logic [K_CMDWIDTH-1:0] i_cmd          ,
	input  logic [K_BUFWIDTH-1:0] i_param_min_off, //!
	output logic                  o_power
);


	logic [K_BUFWIDTH-1:0] t_step;
	logic [K_BUFWIDTH-1:0] t_on  ;
	logic [K_BUFWIDTH-1:0] t_off ;
	logic [K_BUFWIDTH-2:0] t_pre ;
	logic [K_BUFWIDTH-2:0] t_post;

	logic [K_BUFWIDTH-2:0] cnt_pre;

	logic t_pre_elapsed;
	logic restart      ;

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_pre_counter
		if (~ i_rst_n ) begin
			cnt_pre       <= 0;
			t_pre_elapsed <= 0;
		end else begin
			t_pre_elapsed <= 0;
			if(restart) begin
				t_pre_elapsed <= 0;
				cnt_pre       <= 0;
			end
			if (cnt_pre == t_pre) begin
				t_pre_elapsed <= 1;
			end else begin
				cnt_pre <= cnt_pre +1;
			end
		end
	end

endmodule