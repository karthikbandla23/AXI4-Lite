class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
    virtual axi4_lite_if aif;
    uvm_analysis_port #(transaction) aport;
    transaction tr;

    function new(string path = "monitor", uvm_component parent);
        super.new(path, parent);
        aport = new("aport", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("tr", this);
        if(!uvm_config_db #(virtual axi4_lite_if)::get(this, "", "aif", aif)) `uvm_fatal(get_type_name(), "Not able to access interface")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(posedge aif.ACLK);
            @(posedge aif.ACLK);
            tr.read_s = aif.rd_en;
            tr.write_s = aif.wr_en;
            tr.ARESETN = aif.ARESETN;
            @(posedge aif.ACLK);
            if(tr.write_s && ~tr.read_s) begin
                wait(aif.AWVALID && aif.AWREADY);
                tr.Write_Address = aif.AWADDR;
                wait(aif.WVALID && aif.WREADY)
                tr.Write_Data = aif.WDATA;
                wait(aif.BREADY && aif.BVALID);
                end
            else if(tr.read_s && ~tr.write_s) begin
                tr.Write_Data = 0;
                tr.Write_Address = 0;
                wait(aif.ARVALID && aif.ARREADY)
                tr.Read_Address = aif.ARADDR;
                wait(aif.RREADY && aif.RVALID)
                tr.Read_Data = aif.RDATA;     
            end
            else if(tr.read_s && tr.write_s) begin
                fork
                    begin
                        wait(aif.ARVALID && aif.ARREADY)
                        tr.Read_Address = aif.ARADDR;
                        wait(aif.RREADY && aif.RVALID)
                        tr.Read_Data = aif.RDATA;   
                    end  

                    begin
                        wait(aif.AWVALID && aif.AWREADY)
                        tr.Write_Address = aif.AWADDR;
                        wait(aif.WVALID && aif.WREADY)
                        tr.Write_Data = aif.WDATA;
                        wait(aif.BREADY && aif.BVALID);
                    end
                join
            end

            `uvm_info(get_type_name(), $sformatf("RESET = %0b, rd_en = %0d, wr_en = %0d, Write_Address = %0d, Read_Address = %0d, Write_Data = %0x, Data_Read = %0x", tr.ARESETN, tr.read_s, tr.write_s, tr.Write_Address, tr.Read_Address, tr.Write_Data, tr.Read_Data), UVM_NONE)
            aport.write(tr);
            @(posedge aif.ACLK);
        end 
    endtask

endclass
