interface reg_rdchan_if #(parameter int K_DWIDTH=8,parameter int  K_AWIDTH=16);
 logic [K_AWIDTH-1:0] addr;  // Register read address
 logic                read;  // Register read command
 logic [K_DWIDTH-1:0] data;  // Register read data
 logic                valid; // Register valid data

modport slave(
 input  addr,
 input  read,
 output data,
 output valid
);

modport master(
 output addr,
 output read,
 input  data,
 input  valid
);

modport monitor(
 input addr,
 input read,
 input data,
 input valid
);

endinterface : reg_rdchan_if
