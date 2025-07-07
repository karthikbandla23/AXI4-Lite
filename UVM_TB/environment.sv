class environment extends uvm_env;
    `uvm_component_utils(environment)
    agent ag;
    scoreboard sco;

    function new(string path = "environment", uvm_component parent);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ag = agent::type_id::create("ag", this);
        sco = scoreboard::type_id::create("sco", this);
        `uvm_info(get_type_name(), "Memory is created for agent and Scoreboard ", UVM_NONE)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ag.mon.aport.connect(sco.aimport);
        `uvm_info(get_type_name(), "Monitor and Scoreboard are connected", UVM_NONE)
    endfunction

endclass
