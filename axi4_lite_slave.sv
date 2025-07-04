//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2024 03:21:17 PM
// Design Name: 
// Module Name: axi4_lite_slave
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

module axi4_lite_slave #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
    )
    (
        //Global Signals
        input                           ACLK,
        input                           ARESETN,

        ////Read Address Channel INPUTS
        input           [ADDRESS-1:0]   S_ARADDR,
        input                           S_ARVALID,
        //Read Data Channel INPUTS
        input                           S_RREADY,
        //Write Address Channel INPUTS
        /* verilator lint_off UNUSED */
        input           [ADDRESS-1:0]   S_AWADDR,
        input                           S_AWVALID,
        //Write Data  Channel INPUTS
        input          [DATA_WIDTH-1:0] S_WDATA,
        input          [3:0]            S_WSTRB,
        input                           S_WVALID,
        //Write Response Channel INPUTS
        input                           S_BREADY,	

        //Read Address Channel OUTPUTS
        output logic                    S_ARREADY,
        //Read Data Channel OUTPUTS
        output logic    [DATA_WIDTH-1:0]S_RDATA,
        output logic         [1:0]      S_RRESP,
        output logic                    S_RVALID,
        //Write Address Channel OUTPUTS
        output logic                    S_AWREADY,
        output logic                    S_WREADY,
        //Write Response Channel OUTPUTS
        output logic         [1:0]      S_BRESP,
        output logic                    S_BVALID
    );

    localparam no_of_registers = 32;

    logic [DATA_WIDTH-1 : 0] register [no_of_registers-1 : 0];
    logic [ADDRESS-1 : 0]    addr;
    logic  write_addr;
    logic  write_data;

    typedef enum logic [2 : 0] {IDLE,WADDR_CHANNEL, WRITE_CHANNEL,WRESP_CHANNEL, RADDR_CHANNEL, RDATA_CHANNEL} state_type;
    state_type state , next_state;

    // AR
    assign S_ARREADY = (state == RADDR_CHANNEL) ? 1 : 0;
    // 
    assign S_RVALID = (state == RDATA_CHANNEL) ? 1 : 0;
    assign S_RDATA  = (state == RDATA_CHANNEL) ? register[addr] : 0;
    assign S_RRESP  = (state == RDATA_CHANNEL) ?2'b00:0;
    // AW
    assign S_AWREADY = (state == WADDR_CHANNEL) ? 1 : 0;
    // W
    assign S_WREADY = (state == WRITE_CHANNEL) ? 1 : 0;
    // B
    assign S_BVALID = (state == WRESP_CHANNEL) ? 1 : 0;
    assign S_BRESP  = (state == WRESP_CHANNEL )? 0:0;

    integer i;

    always_ff @(posedge ACLK) begin
        // Reset the register array
        if (~ARESETN) begin
            for (i = 0; i < 32; i++) begin
                register[i] <= 32'b0;
            end
        end
        else begin
            if(state == WADDR_CHANNEL) begin
                addr <= S_AWADDR;
            end
            else if (state == WRITE_CHANNEL) begin
                register[addr] <= S_WDATA;
            end
            else if (state == RADDR_CHANNEL) begin
                addr <= S_ARADDR;
            end
        end
    end

    always_ff @(posedge ACLK) begin
        if (!ARESETN) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
		case (state)
            IDLE : begin
                if (S_AWVALID) begin
                    next_state = WADDR_CHANNEL;
                end 
                else if (S_ARVALID) begin
                    next_state = RADDR_CHANNEL;
                end 
                else begin
                    next_state = IDLE;
                end
            end
            RADDR_CHANNEL   : if (S_ARVALID && S_ARREADY ) next_state = RDATA_CHANNEL;
            RDATA_CHANNEL   : if (S_RVALID  && S_RREADY  ) next_state = IDLE;
            WADDR_CHANNEL   : if (S_AWVALID && S_AWREADY ) next_state = WRITE_CHANNEL;
            WRITE_CHANNEL   : if (S_WVALID && S_WREADY) next_state = WRESP_CHANNEL;
            WRESP_CHANNEL   : if (S_BVALID  && S_BREADY  ) next_state = IDLE;
            default : next_state = IDLE;
        endcase
    end
endmodule