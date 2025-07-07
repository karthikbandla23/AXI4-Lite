
module axi4_lite_master #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
    )
    (
        //Global Signals
        input                           START_READ,
        input                           START_WRITE,

        input          [ADDRESS-1 : 0]  Read_Address,
        input          [ADDRESS-1 : 0]  Write_Address,
        input          [DATA_WIDTH-1:0]  W_data,

        axi4_lite_if.master_if M
    );
    logic read_start;
    logic write_start;

    typedef enum logic [1 : 0] {W_IDLE, WADDR_CHANNEL, WRITE_CHANNEL, WRESP_CHANNEL} w_state_type;
    typedef enum logic [1 : 0] {R_IDLE, RADDR_CHANNEL, RDATA_CHANNEL} r_state_type;

    w_state_type w_state , w_next_state;
    r_state_type r_state , r_next_state;


    //ar
    assign M.ARADDR  = (r_state == RADDR_CHANNEL) ? Read_Address : 32'h0;
    assign M.ARVALID = (r_state == RADDR_CHANNEL) ? 1 : 0;
    //r
    assign M.RREADY  = (r_state == RDATA_CHANNEL || r_state == RADDR_CHANNEL) ? 1 : 0;
    //aw
    assign M.AWVALID = (w_state == WADDR_CHANNEL) ? 1 : 0;
    assign M.AWADDR  = (w_state == WADDR_CHANNEL) ? Write_Address : 32'h0;
    //W
    assign M.WVALID  = (w_state == WRITE_CHANNEL) ? 1 : 0;
    assign M.WDATA   = (w_state == WRITE_CHANNEL) ? W_data : 32'h0;
    // assign M.WSTRB   = (w_state == WRITE_CHANNEL)  ?4'b1111:0;
    // B
    assign M.BREADY = ((w_state == WRITE_CHANNEL)||(w_state == WRESP_CHANNEL)) ? 1 : 0;


    always_ff @(posedge M.ACLK) begin
        if (~M.ARESETN) begin
            w_state <= W_IDLE;
        end else begin
            w_state <= w_next_state;
        end
    end

    always_ff @(posedge M.ACLK) begin
        if (~M.ARESETN) begin
            r_state <= R_IDLE;
        end else begin
            r_state <= r_next_state;
        end
    end

    
    always_ff @(posedge M.ACLK) begin
        if (~M.ARESETN) begin
           read_start <= 0;
           write_start<= 0;
        end 
        else begin
           read_start <= START_READ;
           write_start<= START_WRITE;
        end
    end
    
    always_comb begin
		case (w_state)
            W_IDLE : begin
                if (write_start) begin
                    w_next_state = WADDR_CHANNEL;
                end 
                else begin
                    w_next_state = W_IDLE;
                end
            end
            WADDR_CHANNEL  : if (M.AWVALID && M.AWREADY) w_next_state = WRITE_CHANNEL;
            WRITE_CHANNEL  : if (M.WVALID  && M.WREADY) w_next_state = WRESP_CHANNEL;
            WRESP_CHANNEL : if (M.BVALID  && M.BREADY) w_next_state = W_IDLE;
			default : w_next_state = W_IDLE;
		endcase
	end

    always_comb begin
		case (r_state)
            R_IDLE : begin
                if (read_start) begin
                    r_next_state = RADDR_CHANNEL;
                end 
                else begin
                    r_next_state = R_IDLE;
                end
            end
			RADDR_CHANNEL  : if (M.ARVALID && M.ARREADY) r_next_state = RDATA_CHANNEL;
			RDATA_CHANNEL : if (M.RVALID  && M.RREADY) r_next_state = R_IDLE;
			default : r_next_state = R_IDLE;
		endcase
	end

endmodule