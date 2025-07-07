class read_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(read_sequence)
    transaction tr;
    function new(string path = "read_sequence");
        super.new(path);
    endfunction

    task body();
        repeat(32) begin
           tr = transaction::type_id::create("tr");
           start_item(tr);
           assert(tr.randomize());
           tr.ARESETN = 1;
           tr.read_s = 1;
           tr.write_s = 0;
           tr.Write_Address = 0;
           tr.Write_Data = 0;
           `uvm_info(get_type_name(), "Read sequence sent to Driver", UVM_NONE)
           finish_item(tr);
        end
    endtask

endclass

class read_and_write_sequence extends uvm_sequence #(transaction);
    `uvm_object_utils(read_and_write_sequence)
    transaction tr;
    function new(string path = "read_and_write_sequence");
        super.new(path);
    endfunction

    task body();
        repeat(10) begin
           tr = transaction::type_id::create("tr");
           start_item(tr);
           assert(tr.randomize());
           tr.ARESETN = 1;
           tr.read_s = 1;
           tr.write_s = 1;
           `uvm_info(get_type_name(), "Read and Write sequence sent to Driver", UVM_NONE)
           finish_item(tr);
        end
    endtask

endclass