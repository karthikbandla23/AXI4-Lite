class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    uvm_analysis_imp #(transaction, scoreboard) aimport;
    bit [31:0]mem [31:0];
    function new(string path = "scoreboard", uvm_component parent);
        super.new(path, parent);
        aimport = new("aimport", this);
    endfunction

    virtual function void write(input transaction tr);
        if(~tr.ARESETN)
            `uvm_info(get_type_name(), "RESET DETECTED", UVM_NONE)
        else begin
            if((tr.write_s && ~tr.read_s)) begin
                mem[tr.Write_Address] = tr.Write_Data;
                `uvm_info(get_type_name(), $sformatf("Written to location = %0d, Data Written = %0x", tr.Write_Address, tr.Write_Data), UVM_NONE)
            end
            if((tr.read_s && ~tr.write_s)) begin
                if (tr.Read_Data !== mem[tr.Read_Address]) `uvm_error(get_type_name(), $sformatf("Data mismatched after Read, Read data from Reference model = %0d, From DUT = %0d", mem[tr.Read_Address], tr.Read_Data))
                else `uvm_info(get_type_name(), $sformatf("Data matched after the Read, Read data from Reference model = %0x, From DUT = %0x", mem[tr.Read_Address], tr.Read_Data), UVM_NONE)
            end
            if((tr.read_s && tr.write_s) && (tr.Write_Address == tr.Read_Address)) begin
                `uvm_error(get_type_name(), "Writing to and Reading from same location at a time")
            end
            else if ((tr.read_s && tr.write_s) && (tr.Write_Address != tr.Read_Address))begin
                mem[tr.Write_Address] = tr.Write_Data;
                `uvm_info(get_type_name(), $sformatf("Written to location = %0d, Data Written = %0x", tr.Write_Address, tr.Write_Data), UVM_NONE)
                if (tr.Read_Data !== mem[tr.Read_Address]) `uvm_error(get_type_name(), "Data Mismatched while Reading")
                else `uvm_info(get_type_name(), $sformatf("Data matched after the Read, Data Read from Reference model = %0x, From DUT = %0x", mem[tr.Read_Address], tr.Read_Data), UVM_NONE)
            end
        end
        `uvm_info(get_type_name(), "------------------------------------------------------------------------------------------------", UVM_NONE)
    endfunction 
endclass
