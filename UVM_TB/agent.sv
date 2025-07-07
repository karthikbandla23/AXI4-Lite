class agent extends uvm_agent;
    `uvm_component_utils(agent)
    driver dri;
    monitor mon;
    uvm_sequencer #(transaction) sqr;

    function new(string path = "agent", uvm_component parent);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer #(transaction)::type_id::create("sqr", this);
        dri = driver::type_id::create("dri", this);
        mon = monitor::type_id::create("mon", this);
        `uvm_info(get_type_name(), "Memory is created for sequencer, driver, monitor", UVM_NONE)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        dri.seq_item_port.connect(sqr.seq_item_export);
        `uvm_info(get_type_name(), "Sequencer and Driver are Connected", UVM_NONE)
    endfunction

endclass
