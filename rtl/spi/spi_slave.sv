module spi_slave #(parameter  K_DWIDTH = 16) (
	input  logic                i_clk          , //! System clock
	input  logic                i_rst_n        , //! System reset
	// Top level signals
	input  logic [K_DWIDTH-1:0] i_data_to_send , //! data to be sent.
	input  logic                i_valid_data   , //! Data valid for data to send
	output logic [K_DWIDTH-1:0] o_data_recieved, //! Data recieved
	output logic                o_rx_event     , //! Data was recieved.
	output logic                o_txe          , //!
	output logic                o_selected     , //! Internal registered CSn
	// Parameters
	input  logic                i_cpol         , //! Clock polarity
	input  logic                i_cpha         , //! Clock phase
	// SPI signals
	input  logic                i_mosi         , //! SPI slave data input
	input  logic                i_spi_clk      , //! SPI clock
	input  logic                i_cs_n         , //! Chip select
	output logic                o_miso           //! SPI Slave out
);

	logic trigger_capture     ;
	logic trigger_send        ;
	logic spi_clk_rising_edge ;
	logic spi_clk_falling_edge;

	logic start_sequence  ;
	logic previous_spi_clk;
	logic previous_csn    ;

	logic [K_DWIDTH-1:0] mosi_buffer;
	logic [K_DWIDTH-2:0] miso_buffer;

	logic [$clog2(K_DWIDTH):0] input_counter;

	logic trigger_new_sequence   ;
	logic transmit_data_to_system;

	//! Various edge detections

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_edge_detection
		if (~ i_rst_n ) begin
			spi_clk_rising_edge  <= 0;
			spi_clk_falling_edge <= 0;
			previous_spi_clk     <= 0;
			previous_csn         <= 0;
		end else begin
			previous_spi_clk     <= i_spi_clk;
			spi_clk_rising_edge  <= ~previous_spi_clk & i_spi_clk;
			spi_clk_falling_edge <= previous_spi_clk & ~i_spi_clk;
			previous_csn         <= i_cs_n;
			start_sequence       <= ~i_cs_n & previous_csn | trigger_new_sequence;
		end
	end

	assign trigger_capture = ((i_cpha == i_cpol) ? spi_clk_rising_edge : spi_clk_falling_edge) & ~i_cs_n;
	assign trigger_send    = ((i_cpha == i_cpol) ? spi_clk_falling_edge : spi_clk_rising_edge) & ~i_cs_n;

	//! Buffering
	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_buffering
		if (~ i_rst_n ) begin
			input_counter           <= 0;
			mosi_buffer             <= 0;
			miso_buffer             <= 0;
			trigger_new_sequence    <= 0;
			o_rx_event              <= 0;
			o_data_recieved         <= 0;
			o_selected              <= 0;
			o_txe                   <= 1;
			transmit_data_to_system <= 0;
		end else begin
			trigger_new_sequence <= 0;
			o_rx_event           <= 0;
			o_selected           <= ~ i_cs_n ;
			transmit_data_to_system <= 0;
			if(start_sequence) begin
				mosi_buffer   <= 0;
				input_counter <= K_DWIDTH-1;
			end
			if(~i_cs_n) begin
				if(trigger_capture) begin
					input_counter <= input_counter -1;
					mosi_buffer   <= {mosi_buffer[K_DWIDTH-2:0],i_mosi};
					if(input_counter == 0) begin
						transmit_data_to_system <= 1;
						trigger_new_sequence <= 1;
					end
				end
				if (transmit_data_to_system) begin
					o_data_recieved      <= mosi_buffer;
					o_rx_event           <= 1;
					o_txe                <= 1;
				end
				if(trigger_send) begin
					{o_miso,miso_buffer} <= {miso_buffer,1'b0};
				end
			end else if (o_selected & i_cs_n) begin
				// On CSN falling edge, flush output 
				o_miso <= 0;
				miso_buffer <= 0;
			end

			if(i_valid_data) begin
				{o_miso,miso_buffer} <= i_data_to_send;
				o_txe <= 0;
			end
		end
	end

endmodule
