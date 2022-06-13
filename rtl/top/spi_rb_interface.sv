module spi_rb_interface (
	input  logic         i_clk         , //! Main clock
	input  logic         i_rst_n       , //! Main reset
	// Regbank interfaces
	reg_wrchan_if.master mif_wr_rb     ,
	reg_rdchan_if.master mif_rd_rb     ,
	// SPI interface
	input  logic [15:0]  i_spi_in_data , //!
	output logic [15:0]  o_spi_out_data,
	input  logic         i_spi_rx      , //!
	input  logic         i_spi_txe     , //!
	input  logic         i_csn         , //!
	output logic         o_spi_valid_tx  //! Valid Tx DATA
);


	const logic [7:0] K_READ  = 8'b00000001;
	const logic [7:0] K_WRITE = 8'b00000010;

	const logic [15:0] K_ACK = 16'h4F4B; //OK

	logic [7:0] part_address;
	logic [7:0] part_cmd    ;

	logic [7:0] address;
	logic [7:0] cmd    ;

	logic [15:0] data_in ;
	logic [15:0] data_out;

	logic decode_wren ;
	logic decode_rden ;
	logic decode_valid;

	assign {part_cmd,part_address} = i_spi_in_data;

	typedef enum { IDLE, READING, WRITING, LOCKED } spi_state_t;
	spi_state_t state_spi     ;
	spi_state_t state_spi_next;


	always_comb begin : p_comb_fsm
		state_spi_next = state_spi;
		case (state_spi)
			IDLE :
				begin
					if (i_spi_rx) begin
						case (part_cmd)
							K_READ  : state_spi_next = READING;
							K_WRITE : state_spi_next = WRITING;
							default : state_spi_next = LOCKED;
						endcase
					end
				end
			READING :
				begin
					state_spi_next = READING;
				end

			WRITING :
				begin
					if (i_spi_rx) begin
						state_spi_next = LOCKED;
					end else begin
						state_spi_next = WRITING;
					end

				end
			LOCKED :
				begin
					state_spi_next = LOCKED;
				end
			default :
				begin
					state_spi_next = IDLE;
				end
		endcase
	end



	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_frame_control
		if (~ i_rst_n ) begin
			address   <= 0;
			state_spi <= IDLE;

			mif_rd_rb.read <= 0;
			o_spi_valid_tx <= 0;
		end else begin

			o_spi_valid_tx <= 0;
			mif_rd_rb.read <= 0;

			if (i_csn) begin
				state_spi <= IDLE;
			end else begin
				state_spi <= state_spi_next;

				if (state_spi_next == READING) begin
					if (i_spi_rx) begin
						// Get regbank and write to SPI

						mif_rd_rb.read <= 1;
						address        <= state_spi == IDLE ? part_address :  address +1;
					end
					if(mif_rd_rb.valid) begin
						o_spi_out_data <= mif_rd_rb.data;
						o_spi_valid_tx <= 1;
					end
				end else if (state_spi_next == WRITING) begin
					if (state_spi != WRITING)  begin
						address <= part_address;
						mif_rd_rb.read <= 1;
					end
				end
				if (state_spi == WRITING) begin
					if(mif_rd_rb.valid) begin
						o_spi_out_data <= mif_rd_rb.data;
						o_spi_valid_tx <= 1;
					end
					if (i_spi_rx) begin
						// Generate write access and go into locked state
						mif_wr_rb.write <= 1;
						mif_wr_rb.data  <= i_spi_in_data;
					end
				end
			end
		end
	end
	assign mif_rd_rb.addr  = address;
	assign mif_wr_rb.addr  = address;
	assign mif_wr_rb.bmask = 0 ;

endmodule
