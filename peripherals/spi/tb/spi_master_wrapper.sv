module spi_master_wrapper ();

	logic        clk     ;
	logic        rstn    ;
	logic [15:0] data    ;
	logic        valid   ;
	logic        spi_clk ;
	logic        spi_csn ;
	logic        spi_miso;
	logic        spi_mosi;


	if_spi if_fromslave ();

	assign if_fromslave.clk  = spi_clk;
	assign if_fromslave.csn  = spi_csn;
	assign if_fromslave.miso = spi_miso;

	assign spi_mosi = if_fromslave.mosi;

	spi_master #(
		.K_WIDTH(  
		         16)  
	) spi_master_dut (
		.i_clk       (clk         ),
		.i_rstn      (rstn        ),
		.mif_external(if_fromslave),
		.o_data      (data        ),
		.o_valid     (valid       )
	);


endmodule;