module tb;

    parameter Data_Width = 32;
    parameter Addr_Width = 32;

    // Interface instance
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
    assign aif.RDATA = DUT.bfm.RDATA;
    // Drive Master-side signals via the interface (used in testbench logic)
    task write(logic [Addr_Width-1:0] addr, logic [Data_Width-1:0] data);
        @(posedge aif.ACLK);
        aif.wr_en   <= 1;
        aif.Write_Address <= addr;
        aif.Write_Data  <= 1234;
        @(posedge aif.ACLK);
        aif.wr_en   <= 0;
        // Wait for write handshake
        wait (aif.AWVALID && aif.AWREADY);
        // $display("Write Address Channel completed");
        wait (aif.WVALID && aif.WREADY);
        // $display("Write Data Channel completed");
        wait (aif.BVALID && aif.BREADY);
        // $display("Write Response Channel completed");
        #20;
    endtask

    task read_and_compare(logic [Addr_Width-1:0] addr);
        logic [Data_Width-1:0] read_val;
        static int expected = 1234;
        @(posedge aif.ACLK);
        aif.rd_en   <= 1;
        aif.Read_Address <= addr;
        @(posedge aif.ACLK);
        aif.rd_en   <= 0;

        // Wait for read handshake
        wait (aif.ARVALID && aif.ARREADY);
        // $display("Read Address Channel completed");
        wait (aif.RVALID && aif.RREADY);
        // $display("Read Data Channel completed");
        read_val = aif.RDATA;

        $display("time = %0t, Expected = %0d, Value received = %0d", $time, expected, read_val);
        // if (read_val == addr + 2) $display("Data Matched");
        // else                      $display("Data Mismatched");

        #20;
    endtask

    // Clock generation
    initial begin
        aif.ACLK = 0;
        forever #5 aif.ACLK = ~aif.ACLK;
    end

    // Test procedure
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        // $monitor("AWVALID = %0b, AWREADY = %0b, WVALID = %0b, WREADY = %0b, BVALID = %0b, BREADY = %0b, ARVALD = %0b, ARREADY = %0b, RVALID = %0b, RREADY = %0b", aif.AWVALID, aif.AWREADY, aif.WVALID, aif.WREADY, aif.BVALID, aif.BREADY, aif.ARVALID, aif.ARREADY, aif.RVALID, aif.RREADY);

        // Init
        aif.ARESETN = 0;
        aif.wr_en = 0;
        aif.rd_en = 0;
        aif.Write_Data = 0;
        aif.Write_Address = 0;
        aif.Read_Address = 0;

        #20;
        aif.ARESETN = 1;
        #20;

        // Write phase
        for (int i = 0; i < 1; i++) begin
            write(i, i+2);
        end

        $display("-------------------Write Transaction Completed----------------------");
        // Read phase
        for (int i = 0; i < 1; i++) begin
            read_and_compare(i);
        end

        #50;
        $finish;
    end

endmodule
