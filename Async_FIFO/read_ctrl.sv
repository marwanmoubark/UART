module read_ctrl #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
)(
    input                               rclk,
    input                               rrst_n,
    input                               rinc,
    input        [ADDR_WIDTH : 0]       rq2_wptr,
    output wire  [ADDR_WIDTH - 1: 0]    raddr,
    output reg   [ADDR_WIDTH : 0]       rptr, 
    output wire                         rempty
);

    reg [ADDR_WIDTH : 0] raddr_reg;

    assign r_en  = !rempty && rinc;
    assign raddr = raddr_reg[ADDR_WIDTH - 1 : 0];

    // Compute NEXT binary and Gray values combinationally
    wire [ADDR_WIDTH : 0] raddr_next = raddr_reg + (r_en ? 1'b1 : 1'b0);
    wire [ADDR_WIDTH : 0] rptr_next  = raddr_next ^ (raddr_next >> 1);

    // Register both synchronously on the same cycle
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            raddr_reg <= 'd0;
            rptr      <= 'd0;
        end else begin
            raddr_reg <= raddr_next;
            rptr      <= rptr_next;
        end
    end

    // Empty flag logic
    assign rempty = (rptr == rq2_wptr);

endmodule