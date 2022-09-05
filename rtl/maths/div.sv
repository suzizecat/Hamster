// Project F Library - Division (Fixed-Point)
// (C)2021 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module div #(
	parameter int WIDTH = 4, // width of numbers in bits
	parameter int FBITS = 0  // fractional bits (for fixed point)
) (
	input  logic             i_clk  ,
	input  logic             i_start, // i_start signal
	output logic             o_busy , // calculation in progress
	output logic             o_valid, // quotient and remainder are o_valid
	output logic             o_dbz  , // divide by zero flag
	output logic             o_ovf  , // overflow flag (fixed-point)
	input  logic [WIDTH-1:0] i_x    , // dividend
	input  logic [WIDTH-1:0] i_y    , // divisor
	output logic [WIDTH-1:0] o_q    , // quotient
	output logic [WIDTH-1:0] o_r      // remainder
);

	// avoid negative vector width when fractional bits are not used
	localparam int FBITSW = (FBITS != 0) ? FBITS : int'(1);

	logic [WIDTH-1:0] y1     ; // copy of divisor
	logic [WIDTH-1:0] q1     ;
	logic [WIDTH-1:0] q1_next; // intermediate quotient
	logic [  WIDTH:0] ac     ;
	logic [  WIDTH:0] ac_next; // accumulator (1 bit wider)

	localparam int                      ITER = WIDTH+FBITS; // iterations are dividend width + fractional bits
	logic            [$clog2(ITER)-1:0] i                 ; // iteration counter

	always_comb begin
		if (ac >= {1'b0,y1}) begin
			ac_next = ac - y1;
			{ac_next, q1_next} = {ac_next[WIDTH-1:0], q1, 1'b1};
		end else begin
			{ac_next, q1_next} = {ac, q1} << 1;
		end
	end

	always_ff @(posedge i_clk) begin
		if (i_start) begin
			o_valid <= 0;
			o_ovf   <= 0;
			i     <= 0;
			if (i_y == 0) begin  // catch divide by zero
				o_busy <= 0;
				o_dbz  <= 1;
			end else begin
				o_busy <= 1;
				o_dbz  <= 0;
				y1   <= i_y;
				{ac, q1} <= {{WIDTH{1'b0}}, i_x, 1'b0};
			end
		end else if (o_busy) begin
			if (int'(i) == ITER-1) begin  // done
				o_busy  <= 0;
				o_valid <= 1;
				o_q     <= q1_next;
				o_r     <= ac_next[WIDTH:1];  // undo final shift
			end else if (int'(i) == WIDTH-1 && q1_next[WIDTH-1:WIDTH-FBITSW]) begin // overflow?
				o_busy <= 0;
				o_ovf  <= 1;
				o_q    <= 0;
				o_r    <= 0;
			end else begin  // next iteration
				i  <= i + 1;
				ac <= ac_next;
				q1 <= q1_next;
			end
		end
	end
endmodule
