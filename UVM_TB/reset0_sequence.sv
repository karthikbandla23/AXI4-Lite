class reset0_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(reset0_sequence)
    transaction tr;
    function new(string path = "reset_sequence");
        super.new(path);
    endfunction

    task body();
    repeat(5) begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        tr.ARESETN = 0;
        tr.read_s = 0;
        tr.write_s = 0;
        tr.Write_Data = 0;
        tr.Read_Address = 0;
        tr.Write_Address = 0;
        `uvm_info(get_type_name(), "Reset0 sequence sent to Driver", UVM_NONE)
        finish_item(tr);
    end
    endtask

endclass
