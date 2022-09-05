set PERIOD 10
create_clock -name myclk -period $PERIOD [get_ports {i_clk}]