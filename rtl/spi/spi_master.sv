module spi_master #(parameter K_WIDTH = 16) (
	// Top level standards ports
	input  logic               i_clk         ,
	input  logic               i_rstn        ,
	input  logic               i_spi_clk     ,
	input  logic               i_confirm_data,
	// External interface
	if_spi.master              mif_external  ,
	// Internal interface
	output logic [K_WIDTH-1:0] o_data        ,
	input  logic [K_WIDTH-1:0] i_data        ,
	output logic               o_valid
);

	logic [K_WIDTH-1:0] input_miso_buffer    ;
	logic [K_WIDTH-1:0] input_mosi_buffer    ;
	logic [K_WIDTH-1:0] output_buffer        ;
	logic [K_WIDTH-1:0] transmission_status  ;
	logic               valid_shift          ;
	logic               spi_last_clk         ;
	logic               validated_transaction;
	logic               pulse_spi_clk        ;


	typedef enum { IDLE, ONGOING, LAST_BIT } status_t;

	status_t status;


	always_ff @(posedge i_clk or negedge i_rstn) begin : p_spi_clk_pulse
		if (i_rstn == 0) begin
			pulse_spi_clk = 0;
		end else begin
			spi_last_clk  = i_spi_clk;
			pulse_spi_clk = 0;
			if (spi_last_clk != i_spi_clk) begin
				pulse_spi_clk = 1;
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rstn) begin : p_transmission_status
		if (i_rstn == 0) begin
			transmission_status[0]           = 'b1;
			transmission_status[K_WIDTH-1:1] = 'b0;
		end else begin
			if (pulse_spi_clk == 1) begin
				if (status == ONGOING || status == LAST_BIT) begin
					for(int i = 1; i < K_WIDTH ; i++) begin
						transmission_status[i] = transmission_status[i-1];
					end
					transmission_status[0] = transmission_status[K_WIDTH-1];
				end
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rstn) begin : p_data_tx_path
		if (i_rstn == 0) begin
			input_mosi_buffer = 0;
		end else begin
			if (status == IDLE || status == LAST_BIT) begin
				input_mosi_buffer = i_data;
			end else begin
				for(int i = 0; i < K_WIDTH-1 ; i++) begin
					input_mosi_buffer[i] = input_mosi_buffer[i+1];
				end
				input_mosi_buffer[K_WIDTH] = 0;
			end
		end
	end

//  reg [3-1:0] state;
//  localparam
//    IDLE = 0,
//    ONGOING = 1,
//    LAST_BIT = 2;
	always_ff @(posedge i_clk or negedge i_rstn) begin : p_fsm_status
		if (i_rstn == 0) begin
			status = IDLE;
		end
		else begin
			if(pulse_spi_clk == 1) begin
				case(status)
					IDLE :
						begin
							if (i_confirm_data == 1) begin
								status = ONGOING;
							end
						end
					ONGOING :
						begin
							if (transmission_status[KWIDTH-1] == 1) begin
								status = LAST_BIT;
							end
						end
					LAST_BIT :
						begin
							if (i_confirm_data == 1) begin
								status = ONGOING;
							end
							else if (i_confirm_data == 0) begin
								status = IDLE;
							end
						end
				endcase
			end
		end
	end


endmodule;