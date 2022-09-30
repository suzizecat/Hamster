module spi_slave #(parameter int K_DWIDTH = 16) (
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
	//debug
	output logic [ $clog2(K_DWIDTH)-1:0] o_dbg_mosi_cnt  ,
	output logic [ $clog2(K_DWIDTH)-1:0] o_dbg_miso_cnt  ,
	output logic dgb_clk_rise,
	output logic dbg_clk_fall,
	// SPI signals
	input  logic                i_mosi         , //! SPI slave data input
	input  logic                i_spi_clk      , //! SPI clock
	input  logic                i_cs_n         , //! Chip select
	output logic                o_miso           //! SPI Slave out
);

	localparam int K_CNT_WIDTH  = $clog2(K_DWIDTH);
	localparam int K_BUFF_WIDTH = (2**K_CNT_WIDTH);

	logic prev_csn    ;
	logic prev_spi_clk;

	logic trig_capture       ;
	logic trig_send          ;
	logic trig_decrement_cnt_mosi ;
	logic trig_decrement_cnt_miso ;
	logic trig_handle_buffers;
	
	logic lock;

	logic clk_rising_edge ;
	logic clk_falling_edge;

	logic [ K_CNT_WIDTH-1:0] mosi_cnt  ;
	logic [ K_CNT_WIDTH-1:0] miso_cnt  ;
	logic [K_BUFF_WIDTH-1:0] miso_buff;
	logic [K_BUFF_WIDTH-1:0] mosi_buff;


	assign o_selected = ~prev_csn & ~i_cs_n;

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_edges
		if (~ i_rst_n ) begin
			prev_csn         <= 0;
			prev_spi_clk     <= 0;
			clk_rising_edge  <= 0;
			clk_falling_edge <= 0;
		end else begin
			prev_csn     <= i_cs_n;
			prev_spi_clk <= i_spi_clk;

			if (~i_cs_n) begin
				clk_rising_edge  <= ~ prev_spi_clk & i_spi_clk;
				clk_falling_edge <= prev_spi_clk & ~ i_spi_clk;
			end else begin
				clk_rising_edge  <= 0;
				clk_falling_edge <= 0;
			end
		end
	end

	always_comb begin : p_comb_assign_triggers
		case ({i_cpol,i_cpha})
			2'b00   : {trig_capture, trig_send} = {clk_rising_edge, clk_falling_edge};
			2'b01   : {trig_capture, trig_send} = {clk_falling_edge, clk_rising_edge};
			2'b10   : {trig_capture, trig_send} = {clk_falling_edge, clk_rising_edge};
			2'b11   : {trig_capture, trig_send} = {clk_rising_edge, clk_falling_edge};
			default :
				{trig_capture, trig_send} = 2'b00;
		endcase
	end

	assign trig_decrement_cnt_mosi  = (i_cpha == 1'b1) ? trig_capture : trig_send;
	assign trig_decrement_cnt_miso  = (i_cpha == 1'b1) ? trig_send : trig_capture;
	assign trig_handle_buffers = (! i_cs_n && trig_decrement_cnt_mosi == 1'b1 && mosi_cnt == 0);

	assign o_dbg_mosi_cnt = mosi_cnt;
	assign o_dbg_miso_cnt = miso_cnt;

	assign dgb_clk_rise = clk_rising_edge;
	assign dbg_clk_fall = clk_falling_edge;

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_cnt_mosi
		if (~ i_rst_n ) begin
			mosi_cnt <= K_CNT_WIDTH'(K_DWIDTH - 1);			
		end else begin
			if (i_cs_n) begin
				mosi_cnt <= K_CNT_WIDTH'(K_DWIDTH - 1);
			end else begin
				if (trig_decrement_cnt_mosi) begin
					if(mosi_cnt == 0) begin

						mosi_cnt <= K_CNT_WIDTH'(K_DWIDTH - 1);
					end else begin
						mosi_cnt <= mosi_cnt - 1;
					end
				end
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_cnt_miso
		if (~ i_rst_n ) begin
			miso_cnt <= K_CNT_WIDTH'(K_DWIDTH - 1);			
		end else begin
			if (i_cs_n) begin
				miso_cnt <= K_CNT_WIDTH'(K_DWIDTH - 1);
			end else begin
				if (trig_decrement_cnt_miso) begin
					if(miso_cnt == 0) begin
						miso_cnt <= K_CNT_WIDTH'(K_DWIDTH - 1);
					end else begin
						miso_cnt <= miso_cnt - 1;
					end
				end
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_load_mosi
		if (~ i_rst_n ) begin
			mosi_buff <= 0;
			o_rx_event <= 0;
			o_data_recieved <= 0;
		end else begin
			o_rx_event <= 0; 
			if (trig_capture) begin
				mosi_buff[mosi_cnt] <= i_mosi;
				if(mosi_cnt == 0) begin
					o_rx_event <= mosi_cnt == 0;
					o_data_recieved <= {mosi_buff[K_DWIDTH-1:1],i_mosi};
					
				end
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_send_miso
		if (~ i_rst_n ) begin
			o_miso <= 0;
		end else begin
			if (i_valid_data & ~ i_cs_n) begin
				o_miso <= i_data_to_send[miso_cnt];
			end else if(trig_send) begin
				o_miso <= miso_buff[miso_cnt];
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_handle_buffs
		if (~ i_rst_n ) begin
			miso_buff       <= 0;
			o_txe           <= 1;
			lock <= 0;
		end else begin
			if (~i_cs_n) begin
				lock <= (lock & (|miso_cnt)) | i_valid_data;
				if (i_valid_data) begin
					miso_buff    <= i_data_to_send;
					o_txe        <= 0;
				end else if(trig_handle_buffers & ~lock) begin
					miso_buff       <= 0;
					o_txe           <= 1;
				end
			end else begin
				miso_buff       <= 0;
				o_txe           <= 1;
				lock <= 0;
			end
		end
	end

endmodule
