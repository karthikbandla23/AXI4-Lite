class test extends uvm_test;
    `uvm_component_utils(test)
    environment env;
    reset0_sequence rst0_sq;
    read_sequence rd_sq;
    write_sequence wr_sq;
    read_and_write_sequence rd_wr_sq;

    function new(string path = "test", uvm_component parent);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = environment::type_id::create("env", this);
        `uvm_info(get_type_name(), "Memory is created for Environment ", UVM_NONE)
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        rst0_sq = reset0_sequence::type_id::create("rst0_sq");
        rd_sq = read_sequence::type_id::create("rd_sq");
        wr_sq = write_sequence::type_id::create("wr_sq");
        rd_wr_sq = read_and_write_sequence::type_id::create("rd_wr_sq");

        phase.raise_objection(this);
            rst0_sq.start(env.ag.sqr);
            wr_sq.start(env.ag.sqr);
            rd_sq.start(env.ag.sqr);
            rd_wr_sq.start(env.ag.sqr);
        phase.drop_objection(this);
    endtask

endclass
