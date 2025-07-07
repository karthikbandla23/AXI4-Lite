class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)
    parameter ADDRESS = 32;
    parameter DATA_WIDTH = 32;

    bit read_s, write_s;
    randc bit [ADDRESS-1:0]    Read_Address, Write_Address;
    rand bit [DATA_WIDTH-1:0] Write_Data;
    bit ARESETN;
    bit [DATA_WIDTH-1:0] Read_Data;

    constraint write_address_range {Write_Address inside {[0:31]};}

    constraint read_address_range {Read_Address inside {[0:31]};}

    function new(string path = "transaction");
        super.new(path);
    endfunction

endclass 
