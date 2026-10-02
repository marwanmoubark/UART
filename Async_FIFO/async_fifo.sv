module async_fifo #
(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
)
(
    input                       i_wclk , i_rclk,
    input                       i_wrst_n , i_rrst_n,
    input                       i_wr_en , i_rd_en,
    input  [DATA_WIDTH - 1 : 0] i_data,
    output [DATA_WIDTH - 1 : 0] o_data,
    output                      o_full , o_empty
);

wire [ADDR_WIDTH     : 0] wptr, rptr;
wire [ADDR_WIDTH     : 0] rq2_wptr_sync, wq2_rptr_sync;
wire [ADDR_WIDTH - 1 : 0] raddr , waddr;
wire w_en;
// Instantiate write control
write_ctrl #(
    .DATA_WIDTH (DATA_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_write_ctrl (
    .wclk       (i_wclk),
    .wrst_n     (i_wrst_n),
    .winc       (i_wr_en),
    .wq2_rptr   (wq2_rptr_sync),
    .waddr      (waddr),
    .wptr       (wptr),
    .wfull      (o_full),
    .w_en       (w_en)
);

// Instantiate read control
read_ctrl #(
    .DATA_WIDTH (DATA_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_read_ctrl (
    .rclk       (i_rclk),
    .rrst_n     (i_rrst_n),
    .rinc       (i_rd_en),
    .rq2_wptr  (rq2_wptr_sync),
    .raddr      (raddr),
    .rptr       (rptr),
    .rempty     (o_empty)
);

// Instantiate FIFO memory
fifo_mem_ctrl #(
    .DATA_WIDTH (DATA_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_fifo_mem (
    .wclk     (i_wclk),
    .rst_n    (i_wrst_n),
    .waddr      (waddr[ADDR_WIDTH-1:0]),
    .raddr      (raddr[ADDR_WIDTH-1:0]),
    .wclken     (w_en),
    .wdata      (i_data),
    .rdata      (o_data)
);

df_sync #(
    .DATA_WIDTH (ADDR_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_df_sync_wptr (
    .clk        (i_rclk),
    .rst        (i_rrst_n),
    .i_data     (wptr),
    .o_data     (rq2_wptr_sync)
);

df_sync #(
    .DATA_WIDTH (ADDR_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_df_sync_rptr (
    .clk        (i_wclk),
    .rst        (i_wrst_n),
    .i_data     (rptr),
    .o_data     (wq2_rptr_sync)
);


endmodule
