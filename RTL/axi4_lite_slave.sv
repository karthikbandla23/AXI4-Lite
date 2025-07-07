
module axi4_lite_slave #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
    )
    (
       axi4_lite_if.slave_if S
    );

    localparam no_of_registers = 32;

    logic [DATA_WIDTH-1 : 0] register [no_of_registers - 1: 0];
    logic [ADDRESS-1 : 0]    write_address, read_address;

    typedef enum logic [1 : 0] {W_IDLE, WADDR_CHANNEL, WRITE_CHANNEL, WRESP_CHANNEL} w_state_type;
    typedef enum logic [1 : 0] {R_IDLE, RADDR_CHANNEL, RDATA_CHANNEL} r_state_type;

    w_state_type w_state , w_next_state;
    r_state_type r_state , r_next_state;

    // AR
    assign S.ARREADY = (r_state == RADDR_CHANNEL) ? 1 : 0;
    // 
    assign S.RVALID = (r_state == RDATA_CHANNEL) ? 1 : 0;
    assign S.RDATA  = (r_state == RDATA_CHANNEL) ? register[read_address] : 0;
    assign S.RRESP  = (r_state == RDATA_CHANNEL) ?2'b00:0;
    // AW
    assign S.AWREADY = (w_state == WADDR_CHANNEL) ? 1 : 0;
    // W
    assign S.WREADY = (w_state == WRITE_CHANNEL) ? 1 : 0;
    // B
    assign S.BVALID = (w_state == WRESP_CHANNEL) ? 1 : 0;
    assign S.BRESP  = (w_state == WRESP_CHANNEL )? 0:0;

    integer i;

    always_ff @(posedge S.ACLK) begin
        // Reset the register array
        if (~S.ARESETN) begin
            for (i = 0; i < 32; i++) begin
                register[i] <= 32'b0;
            end
        end
        else begin
            if(w_state == WADDR_CHANNEL) begin
                write_address <= S.AWADDR;
            end
            else if (w_state == WRITE_CHANNEL) begin
                register[write_address] <= S.WDATA;
            end
            if (r_state == RADDR_CHANNEL) begin
                read_address <= S.ARADDR;
            end 
        end
    end

    always_ff @(posedge S.ACLK) begin
        if (!S.ARESETN) begin
            w_state <= W_IDLE;
        end
        else begin
            w_state <= w_next_state;
        end
    end

    always_ff @(posedge S.ACLK) begin
        if (!S.ARESETN) begin
            r_state <= R_IDLE;
        end
        else begin
            r_state <= r_next_state;
        end
    end


    always_comb begin
		case (w_state)
            W_IDLE : begin
                if (S.AWVALID) begin
                    w_next_state = WADDR_CHANNEL;
                end 
                else begin
                    w_next_state = W_IDLE;
                end
            end
            WADDR_CHANNEL   : if (S.AWVALID && S.AWREADY ) w_next_state = WRITE_CHANNEL;
            WRITE_CHANNEL   : if (S.WVALID && S.WREADY) w_next_state = WRESP_CHANNEL;
            WRESP_CHANNEL   : if (S.BVALID  && S.BREADY  ) w_next_state = W_IDLE;
            default : w_next_state = W_IDLE;
        endcase
    end

    always_comb begin
		case (r_state)
            R_IDLE : begin
                if (S.ARVALID) begin
                    r_next_state = RADDR_CHANNEL;
                end 
                else begin
                    r_next_state = R_IDLE;
                end
            end
            RADDR_CHANNEL   : if (S.ARVALID && S.ARREADY ) r_next_state = RDATA_CHANNEL;
            RDATA_CHANNEL   : if (S.RVALID  && S.RREADY  ) r_next_state = R_IDLE;
            default : r_next_state = R_IDLE;    
        endcase
    end

endmodule