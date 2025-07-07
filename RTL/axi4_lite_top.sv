`include "axi4_lite_master.sv"
`include "axi4_lite_slave.sv"
`include "axi4_lite_if.sv"
`include "axi4_lite_Defs.sv"

import axi4_lite_Defs::*;

module axi4_lite_top(
input logic clk, rstn,                                         // system clock
input logic rd_en, wr_en,                                   // read and write enable
input logic [Addr_Width-1:0] Read_Address, Write_Address,   // read and write address variables
input logic [Data_Width-1:0] Write_Data                    // write data variable
);

axi4_lite_if bfm();
assign bfm.ACLK         = clk;
assign bfm.ARESETN      = rstn;

//Instantiate the DUV master and slave:
//Instantiate the master module
axi4_lite_master #(Addr_Width, Data_Width) MP(
    .START_READ(rd_en),
    .START_WRITE(wr_en),
    .Read_Address(Read_Address),
    .Write_Address(Write_Address),
    .W_data(Write_Data),
    .M(bfm.master_if)
);


// instantiate the slave module
axi4_lite_slave #(Addr_Width, Data_Width) SP(
    .S(bfm.slave_if)
);

endmodule