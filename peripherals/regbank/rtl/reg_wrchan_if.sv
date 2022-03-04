interface reg_wrchan_if #(parameter int K_DWIDTH=8,parameter int  K_AWIDTH=16);
	logic [K_AWIDTH-1:0] addr ; // Register write address
	logic [K_DWIDTH-1:0] data ; // Register write data
	logic [K_DWIDTH-1:0] bmask; // Register write bit mask
	logic                write; // Register write command

	modport slave (
		input  addr,
		input  data,
		input  bmask,
		input  write
	);

	modport master (
		output addr,
		output data,
		output bmask,
		output write
	);

	modport monitor (
		input addr,
		input data,
		input bmask,
		input write
	);

endinterface : reg_wrchan_if
