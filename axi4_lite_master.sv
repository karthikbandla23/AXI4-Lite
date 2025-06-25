//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2024 03:21:17 PM
// Design Name: 
// Module Name: axi4_lite_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axi4_lite_master #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
    )
    (
        //Global Signals
        input                           ACLK,
        input                           ARESETN,

        input                           START_READ,
        input                           START_WRITE,

        input          [ADDRESS-1 : 0]  address,
        input          [DATA_WIDTH-1:0]  W_data,

        //Read Address Channel INPUTS
        input                           M_ARREADY,
        //Read Data Channel INPUTS
        /* verilator lint_off UNUSED */
        input          [DATA_WIDTH-1:0] M_RDATA,
        input               [1:0]       M_RRESP,
        input                           M_RVALID,
        //Write Address Channel INPUTS
        input                           M_AWREADY,
        //
        input                           M_WREADY,
        //Write Response Channel INPUTS
        input             [1:0]         M_BRESP,
        input                           M_BVALID,
        //Read Address Channel OUTPUTS
        output logic    [ADDRESS-1 : 0] M_ARADDR,
        output logic                    M_ARVALID,
        //Read Data Channel OUTPUTS
        output logic                    M_RREADY,
        //Write Address Channel OUTPUTS
        output logic    [ADDRESS-1 : 0] M_AWADDR,
        output logic                    M_AWVALID,
        //Write Data  Channel OUTPUTS
        output logic   [DATA_WIDTH-1:0] M_WDATA,
        output logic   [3:0]            M_WSTRB,
        output logic                    M_WVALID,
        //Write Response Channel OUTPUTS
        output logic                    M_BREADY	
    );
    logic read_start;
    logic write_start;

    typedef enum logic [2 : 0] {IDLE, WADDR_CHANNEL, WRITE_CHANNEL, WRESP_CHANNEL, RADDR_CHANNEL, RDATA_CHANNEL} state_type;
    state_type state , next_state;


    //ar
    assign M_ARADDR  = (state == RADDR_CHANNEL) ? address : 32'h0;
    assign M_ARVALID = (state == RADDR_CHANNEL) ? 1 : 0;
    //r
    assign M_RREADY  = (state == RDATA_CHANNEL ||state == RADDR_CHANNEL) ? 1 : 0;
    //aw
    assign M_AWVALID = (state == WADDR_CHANNEL) ? 1 : 0;
    assign M_AWADDR  = (state == WADDR_CHANNEL) ? address : 32'h0;
    //W
    assign M_WVALID  = (state == WRITE_CHANNEL) ? 1 : 0;
    assign M_WDATA   = (state == WRITE_CHANNEL) ? W_data : 32'h0;
    assign M_WSTRB   = (state == WRITE_CHANNEL)  ?4'b1111:0;
    // B
    assign M_BREADY = ((state == WRITE_CHANNEL)||(state == WRESP_CHANNEL)) ? 1 : 0;


    always_ff @(posedge ACLK) begin
        if (~ARESETN) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always_ff @(posedge ACLK) begin
        if (~ARESETN) begin
           read_start <= 0;
           write_start<= 0;
        end 
        else begin
           read_start <= START_READ;
           write_start<= START_WRITE;
        end
    end
    
    always_comb begin
		case (state)
            IDLE : begin
                if (write_start) begin
                    next_state = WADDR_CHANNEL;
                end 
                else if (read_start) begin
                    next_state = RADDR_CHANNEL;
                end 
                else begin
                    next_state = IDLE;
                end
            end
			RADDR_CHANNEL  : if (M_ARVALID && M_ARREADY  ) next_state = RDATA_CHANNEL;
			RDATA_CHANNEL : if (M_RVALID  && M_RREADY   ) next_state = IDLE;
            WADDR_CHANNEL  : if (M_AWVALID && M_AWREADY  ) next_state = WRITE_CHANNEL;
            WRITE_CHANNEL  : if (M_WVALID  && M_WREADY   ) next_state = WRESP_CHANNEL;
            WRESP_CHANNEL : if (M_BVALID  && M_BREADY   ) next_state = IDLE;
			default : next_state = IDLE;
		endcase
	end
endmodule