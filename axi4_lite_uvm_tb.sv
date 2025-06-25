import uvm_pkg::*;
`include "uvm_macros.svh"

class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    rand bit read_s;
    rand bit write_s;
    rand bit [ADDRESS-1:0]    address;
    rand bit [DATA_WIDTH-1:0] W_data;
    rand bit ARESETN;

    function new(string path = "transaction");
        super.new(path);
    endfunction

endclass



class reset0_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(axi_sequence)

    function new(string path = "reset_sequence");
        super.new(axi_sequence);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");
        start_item(tr);
        tr.randomize();
        tr.ARESETN = 0;
        `uvm_info(get_type_name(), "Write sequence sent to Driver", UVM_NONE)
        finish_item(tr)
    endtask

endclass

class reset1_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(axi_sequence)

    function new(string path = "reset_sequence");
        super.new(axi_sequence);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");
        start_item(tr);
        tr.randomize();
        tr.ARESETN = 1;
        `uvm_info(get_type_name(), "Write sequence sent to Driver", UVM_NONE)
        finish_item(tr)
    endtask

endclass


class write_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(axi_sequence)

    function new(string path = "write_sequence");
        super.new(axi_sequence);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");
        repeat(10) begin
           start_item(tr);
           tr.randomize();
           tr.read_s = 0;
           tr.write_s = 1;
           `uvm_info(get_type_name(), "Write sequence sent to Driver", UVM_NONE)
           finish_item(tr)
        end
    endtask

endclass

class  read_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(axi_sequence)

    function new(string path = "read_sequence");
        super.new(axi_sequence);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");
        repeat(10) begin
           start_item(tr);
           tr.randomize();
           tr.read_s = 0;
           tr.write_s = 1;
           `uvm_info(get_type_name(), "Write sequence sent to Driver", UVM_NONE)
           finish_item(tr)
        end
    endtask

endclass


class driver extends uvm_driver #(transaction);
    `uvm_compoennt_utils(driver)
    virtual axi_if aif;

    function new(string path = "driver", uvm_component parent);
        super.new(path, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.new(phase);
        tr = transaction::type_id::create("tr", this);
        if(!uvm_config_db #(virtual axi_if)::get(this, "*", "aif", aif)) `uvm_fatal("Interface is not accessed")
    endfunction

    task drive();
        forever begin 
            seq_item_port.get_next_item(tr);
                @(posedge aif.ACLK);
                aif.ARESETN <= tr.ARESETN;
                aif.read_s <= tr.read_s;
                aif.write_s <= tr.write_s;
                aif.address <= tr.address;
                aif.W_data <= tr.W_data;
            seq_item_port.item_done();

            if(tr.write_s) 
                wait(dut.M_BREADY && dut.S_BVALID);
            else if(tr.read_s)
                wait (dut.S_RVALID && dut.M_RREADY);
        end 
    endtask

    task run_phase(uvm_phase phase);
        super.new(phase);
        drive();
    endtask

endclass


class monitor extends uvm_monitor;

    uvm_component_utils(monitor)
    virtual axi_if aif;
    uvm_analysis_port #(transaction) aport;
    transaction tr;

    function new(string path = "monitor", uvm_component parent);
        super.new(path, parent);
        ap = new("aport", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("tr", this);
        if(uvm_config_db #(virtual axi_if)::get(this, "*", "aif", aif)) `uvm_fatal(get_type_by_name(), "Interface not accessed")
    endfunction

    task run_phase();
        super.run_phase(phase);
        forever begin
            tr.read_s = aif.read_s;
            tr.write_s = aif.write_s;
            tr.ARESETN = aif.ARESETN;

            //Reset
            if(~tr.ARESETN) begin
                @(posedge aif.ACLK);
            end
            else if(tr.write_s) begin
                wait(dut.S_AWREADY && dut.M_AWVALID)
                tr.address = aif.address
                wait(dut.S_WREADY && dut.M_WVALID)
                tr.W_data = aif.W_data;
            end
            else if(tr.read_s) begin
                wait(dut.S_ARREADY && dut.M_ARVALID)
                tr.address = aif.address
                wait(dut.M_RREADY && dut.S_RVALID)
                tr.W_data = aif.;     
            end
            
            tr.address = aif.address;
            tr.W_data = aif.W_data;

            if(tr.write_s) 
                wait(dut.M_BREADY && dut.S_BVALID);
            else if(tr.read_s)
                wait (dut.S_RVALID && dut.M_RREADY);
            aport.write(tr);
        end 
    endtask

endclass

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    uvm_analysis_imp #(transaction, scorerboard) aimport;

    function new(string path = "scoreboard", uvm_component parent);
        super.new(path, parent);
    endfunction
endclass


module axi_tb;
    
    axi_if aif;
    initial begin
        run_test("test");
        uvm_config_db #(virtual axi_if)::set(this, "*", "aif", aif);
    end

endmodule