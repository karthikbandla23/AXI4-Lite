class driver extends uvm_driver  #(transaction);
    `uvm_component_utils(driver)
    virtual axi4_lite_if aif;
    transaction tr;
    function new(string path = "driver", uvm_component parent);
        super.new(path, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("tr", this);
        if(!uvm_config_db #(virtual axi4_lite_if)::get(this, "", "aif", aif)) `uvm_fatal(get_type_name(), "Interface is not accessible")
    endfunction


    task drive();
        forever begin 
            seq_item_port.get_next_item(tr);
                @(posedge aif.ACLK);
                @(negedge aif.ACLK);
                aif.ARESETN <= tr.ARESETN;
                aif.rd_en <= tr.read_s;
                aif.wr_en    <= tr.write_s;
                aif.Write_Address <= tr.Write_Address;
                aif.Read_Address <= tr.Read_Address;
                aif.Write_Data <= tr.Write_Data;
                `uvm_info(get_type_name(), $sformatf("RESET = %0b, rd_en = %0d, wr_en = %0d, Write_Address = %0d, Read_Address = %0d, Write_Data = %0x", tr.ARESETN, tr.read_s, tr.write_s, tr.Write_Address, tr.Read_Address, tr.Write_Data), UVM_NONE)
            if(~tr.ARESETN) @(posedge aif.ACLK);
            @(posedge aif.ACLK);
            aif.rd_en <= 0;
            aif.wr_en    <= 0;
            if(tr.write_s && ~tr.read_s) begin
                wait(aif.BREADY && aif.BVALID);
                end
            else if(tr.read_s && ~tr.write_s) begin
                wait(aif.RREADY && aif.RVALID);
            end
            else if(tr.read_s && tr.write_s) begin
                fork
                    wait(aif.RREADY && aif.RVALID);
                    wait(aif.BREADY && aif.BVALID);
                join
            end
            @(posedge aif.ACLK);
            seq_item_port.item_done();
        end 
    endtask

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        drive();
    endtask

endclass