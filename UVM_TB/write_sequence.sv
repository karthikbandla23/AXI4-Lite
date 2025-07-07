class write_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(write_sequence)
    transaction tr;
    function new(string path = "write_sequence");
        super.new(path);
    endfunction

    task body();
        repeat(32) begin
           tr = transaction::type_id::create("tr");
           start_item(tr);
           assert(tr.randomize());
           tr.ARESETN = 1;
           tr.read_s = 0;
           tr.write_s = 1;
           tr.Read_Address = 0;
           `uvm_info(get_type_name(), "Write sequence sent to Driver", UVM_NONE)
           finish_item(tr);
        end
    endtask

endclass
