interface if_spi;
    logic clk;
    logic csn;
    logic miso;
    logic mosi;

    modport slave (
        input clk,
        input csn,
        input mosi,
        output miso
    );

    modport master (
        output clk,
        output csn,
        output mosi,
        input miso
    );
endinterface //if_spi