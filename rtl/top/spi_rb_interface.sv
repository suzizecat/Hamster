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

	typedef enum { IDLE, RB_REQUEST, SPI_SEND, SPI_WAIT_SENT, SPI_READ } fsm_state_t;
	fsm_state_t fsm_state     ;
	fsm_state_t fsm_state_next;

	const logic [7:0] K_READ  = 8'b01;
	const logic [7:0] K_WRITE = 8'b10;

	logic [7:0] part_address;
	logic [7:0] part_cmd    ;

	logic [7:0] address;
	logic [7:0] cmd    ;

	logic [15:0] data_in ;
	logic [15:0] data_out;

	logic decode_wren ;
	logic decode_valid;
	logic wren        ;

	logic state_load_spi;

	assign {part_cmd,part_address} = i_spi_in_data;

	always_comb begin : p_comb_cmd_decode
		case (part_cmd)
			K_READ :
				begin
					decode_valid = 1;
					decode_wren  = 0;
				end
			K_WRITE :
				begin
					decode_valid = 1;
					decode_wren  = 1;
				end
			default :
				begin
					decode_valid = 0;
					decode_wren  = 0;
				end
		endcase
	end

	always_comb begin : p_comb_fsm
		fsm_state_next = fsm_state;
		case (fsm_state)
			IDLE : begin
				if (i_spi_rx & ~i_csn & decode_valid) begin
					fsm_state_next = RB_REQUEST;
				end
			end
			RB_REQUEST : begin
				if (mif_rd_rb.valid) begin
					fsm_state_next = SPI_SEND;
				end
			end
			SPI_SEND : begin
				fsm_state_next = SPI_WAIT_SENT;
			end

			SPI_WAIT_SENT : begin
				if(i_spi_rx) begin
					fsm_state_next = SPI_READ;
				end
			end
			SPI_READ : begin
				fsm_state_next = RB_REQUEST;
			end
			default :
				fsm_state_next = IDLE;
		endcase
	end

	assign mif_wr_rb.bmask = {16{1'b1}};

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_fsm
		if (~ i_rst_n ) begin
			fsm_state       <= IDLE;
			mif_wr_rb.write <= 0;
			mif_rd_rb.read  <= 0;
			o_spi_valid_tx  <= 0;
			o_spi_out_data  <= 0;

		end else begin
			mif_wr_rb.write <= 0;
			mif_rd_rb.read  <= 0;
			if (i_csn) begin
				fsm_state <= IDLE;
				address   <= 0;
			end	else begin
				fsm_state      <= fsm_state_next;
				o_spi_valid_tx <= 0;
				mif_rd_rb.read <= 0;
				if(fsm_state_next == RB_REQUEST) begin
					mif_rd_rb.addr <= fsm_state == IDLE ? part_address : address;
					if (fsm_state != RB_REQUEST) begin
						mif_rd_rb.read <= 1;
					end
				end
				else if (fsm_state_next == SPI_SEND) begin
					o_spi_out_data <= mif_rd_rb.data;
					o_spi_valid_tx <= 1;
				end
				else if (fsm_state_next == SPI_READ) begin
					if (wren) begin
						mif_wr_rb.addr  <= address;
						mif_wr_rb.write <= 1;
						mif_wr_rb.data  <= i_spi_in_data;
					end
					address <= address +1;
				end
			end
		end
	end

endmodule
