module write_ctrl #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
)(
    input                               wclk,
    input                               wrst_n,
    input                               winc,
    input        [ADDR_WIDTH    : 0]    wq2_rptr,   
    output wire  [ADDR_WIDTH - 1: 0]    waddr,
    output reg   [ADDR_WIDTH    : 0]    wptr,
    output wire                         wfull,
    output wire                         w_en
);

    reg [ADDR_WIDTH : 0] waddr_reg;

    assign w_en  = !wfull && winc;
    assign waddr = waddr_reg[ADDR_WIDTH - 1 : 0];

    // Compute NEXT binary and Gray values combinationally
    wire [ADDR_WIDTH : 0] waddr_next = waddr_reg + (w_en ? 1'b1 : 1'b0);
    wire [ADDR_WIDTH : 0] wptr_next  = waddr_next ^ (waddr_next >> 1); 

    // Register both synchronously on the same cycle
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            waddr_reg <= 'd0;
            wptr      <= 'd0;
        end else begin
            waddr_reg <= waddr_next;
            wptr      <= wptr_next;
        end
    end

    // Full logic comparison
    assign wfull = ((wptr[ADDR_WIDTH]     != wq2_rptr[ADDR_WIDTH])     &&       
                    (wptr[ADDR_WIDTH-1]   != wq2_rptr[ADDR_WIDTH-1])   && 
                    (wptr[ADDR_WIDTH-2:0] == wq2_rptr[ADDR_WIDTH-2:0]));

endmodule