`include "decoder.svh"
//
module spi_rb_interface (
	input  logic         i_clk             , //! Main clock
	input  logic         i_rst_n           , //! Main reset
	// Regbank interfaces
	reg_wrchan_if.master mif_wr_rb         ,
	reg_rdchan_if.master mif_rd_rb         ,
	// SPI interface
	input  logic         i_spi_request_data, //!
	input  logic [15:0]  i_spi_rx_data     ,
	output logic [15:0]  o_spi_tx_data     ,
	output logic         o_spi_tx_valid    , //!
	input  decoded_cmd_t i_command
);

	typedef enum  { IDLE, RB_WRITE, RB_READ, DONE } fsm_state_t;
	fsm_state_t fsm_state     ;
	fsm_state_t fsm_state_next;

	logic rb_access_done;

	logic [7:0] read_address;
	logic [7:0] write_address;

	logic address_is_valid;
	logic access_is_rb;
	logic spi_request_delayed;
	logic write_access_initiated;
	logic write_address_increment;

	assign access_is_rb = fsm_state_next == RB_WRITE || fsm_state_next == RB_READ;

	always_comb begin : p_comb_fsm
		fsm_state_next = fsm_state;
		case (fsm_state)
			IDLE :
				begin if (i_command.valid) begin
						if (i_command.to_register) begin
							if (i_command.write) begin
								fsm_state_next = RB_WRITE;
							end else begin
								fsm_state_next = RB_READ;
							end
						end
					end
				end
			RB_WRITE :
				begin
					if (rb_access_done) begin
						fsm_state_next = DONE;
					end
				end
			RB_READ :
				begin
					if (rb_access_done) begin
						fsm_state_next = DONE;
					end
				end
			DONE :
				begin
					fsm_state_next = DONE;
				end
			default : fsm_state_next = IDLE;
		endcase
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_fsm
		if (~ i_rst_n ) begin
			fsm_state <= IDLE;
		end else begin
			if (i_command.reset_spi) begin
				fsm_state <= IDLE;
			end else begin
				fsm_state <= fsm_state_next;
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_rb_address
		if (~ i_rst_n ) begin
			rb_access_done <= 0;
			read_address <= 0;
			write_address <= 0;
			address_is_valid <= 0;
		end else begin
			rb_access_done <= 0;
			address_is_valid <= 0;
			if (spi_request_delayed & access_is_rb) begin
				address_is_valid <= 1;
				if((&read_address)) begin
					rb_access_done <= 1;
				end else begin
					if(fsm_state == IDLE) begin
						read_address <= i_command.payload;
						write_address <= i_command.payload;
					end else begin
						read_address <= read_address + 1;
						if (write_address_increment) begin
							write_address <= write_address + 1;
						end
					end
				end

			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_delay_spi_valid
		if (~ i_rst_n ) begin
			spi_request_delayed <= 0;
		end else begin
			spi_request_delayed <= i_spi_request_data;
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_data_exchange
		if (~ i_rst_n ) begin
			mif_rd_rb.read  <= 0;
			mif_rd_rb.addr  <= 0;
			o_spi_tx_valid  <= 0;
			mif_wr_rb.addr  <= 0;
			mif_wr_rb.data  <= 0;
			mif_wr_rb.bmask <= 0;
			mif_wr_rb.write <= 0;
			o_spi_tx_data   <= 0;
			write_access_initiated <= 0;
			write_address_increment <= 0;
		end else begin
			mif_rd_rb.read  <= 0;
			o_spi_tx_valid  <= 0;
			mif_wr_rb.bmask <= 0;
			mif_wr_rb.write <= 0;

			if (i_command.reset_spi) begin
				write_access_initiated <= 0;
				write_address_increment <= 0;
			end else if (access_is_rb) begin
				if (address_is_valid) begin
					mif_rd_rb.addr <= read_address;
					mif_rd_rb.read <= 1;
					if (fsm_state == RB_WRITE) begin
						mif_wr_rb.addr  <= write_address;
						mif_wr_rb.data  <= i_spi_rx_data;
						mif_wr_rb.write <= write_access_initiated;
						write_access_initiated <= 1;
						write_address_increment <= write_access_initiated;
					end
				end

				if(mif_rd_rb.valid) begin
					o_spi_tx_valid <= 1;
					o_spi_tx_data  <= mif_rd_rb.data;
				end
			end
		end
	end

endmodule
