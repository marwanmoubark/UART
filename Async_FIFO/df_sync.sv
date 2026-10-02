module df_sync #
(   parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
)
(
    input                         clk , rst,
    input       [ADDR_WIDTH  : 0 ] i_data,
    output wire [ADDR_WIDTH  : 0 ] o_data
);



reg [ADDR_WIDTH  : 0 ] sync_q1, sync_q2;

//-----------double flip flop synchronizer
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        sync_q1 <= 'd0;
        sync_q2 <= 'd0;
    end
    else begin
        sync_q1 <= i_data;
        sync_q2 <= sync_q1;
    end
end

assign o_data = sync_q2;

endmodule
