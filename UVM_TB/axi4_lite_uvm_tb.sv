import uvm_pkg::*;
`include "uvm_macros.svh"
`include "transaction.sv"
`include "reset0_sequence.sv"
`include "write_sequence.sv"
`include "read_sequence.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "environment.sv"
`include "test.sv"

module axi4_lite_tb;
     
    axi4_lite_if aif();

    axi4_lite_top DUT(
        .clk(aif.ACLK),
        .rstn(aif.ARESETN),
        .rd_en(aif.rd_en),
        .wr_en(aif.wr_en),
        .Read_Address(aif.Read_Address),
        .Write_Address(aif.Write_Address),
        .Write_Data(aif.Write_Data)
    );
    assign aif.AWVALID = DUT.bfm.AWVALID;
    assign aif.AWREADY = DUT.bfm.AWREADY;
    assign aif.WVALID = DUT.bfm.WVALID;
    assign aif.WREADY = DUT.bfm.WREADY;
    assign aif.BVALID = DUT.bfm.BVALID;
    assign aif.BREADY = DUT.bfm.BREADY;
    assign aif.ARVALID = DUT.bfm.ARVALID;
    assign aif.ARREADY = DUT.bfm.ARREADY;
    assign aif.RVALID = DUT.bfm.RVALID;
    assign aif.RREADY = DUT.bfm.RREADY;
    assign aif.AWADDR = DUT.bfm.AWADDR;
    assign aif.WDATA = DUT.bfm.WDATA;
    assign aif.ARADDR = DUT.bfm.ARADDR;
    assign aif.RDATA = DUT.bfm.RDATA;

    initial begin
        aif.ACLK = 0;
    end

    always #10 aif.ACLK = ~aif.ACLK;

    initial begin
        uvm_config_db #(virtual axi4_lite_if)::set(null, "*", "aif", aif);
        run_test("test");
    end

endmodule