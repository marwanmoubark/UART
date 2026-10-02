module fifo_mem_ctrl # 
(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
)
(
    input                            wclk,
    input                            rst_n,
    input       [ADDR_WIDTH - 1 : 0] waddr , raddr,
    input                            wclken,
    input       [DATA_WIDTH - 1 : 0] wdata,
    output wire [DATA_WIDTH - 1 : 0] rdata
);


reg [DATA_WIDTH - 1 : 0] fifo [FIFO_DEPTH - 1 : 0];

always@(posedge wclk or negedge rst_n) begin
    if(!rst_n) begin
        for (integer i = 0 ; i < FIFO_DEPTH ; i = i + 1) begin
            fifo[i] <= 0;
        end
    end
    else if(wclken) begin
        fifo[waddr] <= wdata;
    end
end

assign rdata = fifo[raddr];

endmodule