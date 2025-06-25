// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module tb;

    parameter DATA_WIDTH = 32;
    parameter ADDRESS    = 32;

    logic                  ACLK;
    logic                  ARESETN;
    logic                  read_s;
    logic                  write_s;
  logic [ADDRESS-1:0]    address;
  logic [DATA_WIDTH-1:0] W_data;

    // Instantiate the DUT
    axi4_lite_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS(ADDRESS)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .read_s(read_s),
        .write_s(write_s),
        .address(address),
        .W_data(W_data)
    );
  
    task write(logic [ADDRESS-1:0] addr, logic [DATA_WIDTH-1:0] data);
      
      //Issue write
      @(posedge ACLK);
      write_s <= 1;
      address <= addr;
      W_data  <= data;
      
      //disabling write
      @(posedge ACLK);
      write_s <= 0;
      
      //wait till the B response handshake
      wait(dut.M_BREADY && dut.S_BVALID);
      #20;
    endtask
  
    task read_and_compare(logic [ADDRESS-1:0] addr);
      logic [DATA_WIDTH-1:0] read_val;

      // Issue read
      @(posedge ACLK);
      read_s   <= 1;
      address  <= addr;
      @(posedge ACLK);
      read_s   <= 0;

      // Wait for the AXI4-Lite read handshake
      wait (dut.S_RVALID && dut.M_RREADY);

      // Latch and check
      read_val = dut.S_RDATA;
      $display("time = %0t, Expected = %0d, Value recieved = %0d", $time, addr + 2, read_val);
      if(read_val == addr + 2) $display("Data Matched");
      else $display("Data Mismatched");

      #20;
    endtask

  
  
  
  
  
  
    // Clock Generation
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK; // 100MHz clock
    end

    // Reset Logic
    initial begin
      $dumpfile("dump.vcd"); 
      $dumpvars;
        ARESETN = 0;
        read_s = 0;
        write_s = 0;
        address = 0;
        W_data = 0;
        #20;
        ARESETN = 1;
        #20;

        // Write Transaction
      
      for(int i = 0; i < 10; i++) begin
          write(i, i + 2);
        end

        //Read Transaction
      for(int i = 0; i< 10;i++)begin
          read_and_compare(i);
        end
      
     
        #50;
        $finish;
    end

endmodule
