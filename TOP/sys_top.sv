module sys_top #(
    parameter DATA_WIDTH = 8,
    parameter MEM_DEPTH  = 16,
    parameter ADDR_WIDTH = $clog2(MEM_DEPTH)
)(  


    //INTERFACE_PORTS
    input  wire                  REF_CLK,
    input  wire                  UART_CLK,
    input  wire                  RST,
    input  wire                  RX_IN,
    output wire                  TX_OUT,
    output wire                  PAR_ERR,
    output wire                  STP_ERR
);




    // =========================================================================
    // Internal Wires & Connections
    // =========================================================================

 

    // Synchronized Resets
    wire                  SYNC_RST_1;
    wire                  SYNC_RST_2;

    // Register File Dedicated Outputs
    wire [DATA_WIDTH-1:0] REG0_OpA;
    wire [DATA_WIDTH-1:0] REG1_OpB;
    wire [DATA_WIDTH-1:0] REG2_UART_Config;
    wire [DATA_WIDTH-1:0] REG3_Div_Ratio;
    wire [DATA_WIDTH-1:0] RdData;
    wire                  RdData_Valid;
    wire [DATA_WIDTH-1:0] RX_Div_Ratio = 8'd32/({2'b00 ,REG2_UART_Config[7:2]});
    // SYS_CTRL Signals
    wire                  WrEn;
    wire                  RdEn;
    wire [ADDR_WIDTH-1:0] Addr;
    wire [DATA_WIDTH-1:0] WrData;
    wire                  ALU_EN;
    wire [3:0]            ALU_FUN;
    wire                  CLK_EN;
    wire [DATA_WIDTH-1:0] SYS_TX_P_Data;
    wire                  SYS_TX_D_VLD;
    wire                  clk_div_en;

    // ALU Signals
    wire [15:0]           ALU_OUT;
    wire                  OUT_Valid;
    wire                  ALU_CLK;

    // Data Synchronizer Signals
    wire [DATA_WIDTH-1:0] RX_P_Data;
    wire                  RX_D_VLD;
    wire [DATA_WIDTH-1:0] Sync_RX_P_Data;
    wire                  Sync_RX_D_VLD;

    // ASYNC FIFO Signals
    wire                  FIFO_FULL;
    wire                  FIFO_EMPTY;
    wire [DATA_WIDTH-1:0] FIFO_RD_DATA;

    // Pulse Generator & TX Control
    wire                  TX_Busy;
    wire                  PULSE_GEN_RD_INC;

    // Generated Clocks
    wire                  RX_CLK;
    wire                  TX_CLK;

    // =========================================================================
    // DFT INSERTION
    // =========================================================================
    // =========================================================================
    // Synchronizers
    // =========================================================================
    rst_sync u_RST_SYNC_1 (
        .CLK      (REF_CLK),
        .RST_N    (RST),
        .sync_rst (SYNC_RST_1)
    );

    rst_sync u_RST_SYNC_2 (
        .CLK      (UART_CLK),
        .RST_N    (RST),
        .sync_rst (SYNC_RST_2)
    );

    DATA_SYNC #(
        .BUS_WIDTH(DATA_WIDTH)
    ) u_Data_Synchronizer (
        .CLK          (REF_CLK),
        .RST          (SYNC_RST_1),
        .unsync_bus   (RX_P_Data),
        .bus_enable   (RX_D_VLD),
        .sync_bus     (Sync_RX_P_Data),
        .enable_pulse (Sync_RX_D_VLD)
    );

    // =========================================================================
    // Clock Domain 1 (REF_CLK Domain)
    // =========================================================================
    SYS_CTRL #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_SYS_CTRL (
        .CLK          (REF_CLK),
        .RST          (SYNC_RST_1),
        .ALU_OUT      (ALU_OUT),
        .OUT_Valid    (OUT_Valid),
        .RX_P_Data    (Sync_RX_P_Data),
        .RX_D_VLD     (Sync_RX_D_VLD),
        .RdData       (RdData),
        .RdData_Valid (RdData_Valid),
        .FIFO_FULL    (FIFO_FULL),
        .ALU_EN       (ALU_EN),
        .ALU_FUN      (ALU_FUN),
        .CLK_EN       (CLK_EN),
        .Addr         (Addr),
        .WrEN         (WrEn),
        .RdEn         (RdEn),
        .WrData       (WrData),
        .TX_P_Data    (SYS_TX_P_Data),
        .TX_D_VLD     (SYS_TX_D_VLD),
        .clk_div_en   (clk_div_en)
    );

    reg_file #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH (MEM_DEPTH)
    ) u_RegFile (
        .CLK          (REF_CLK),
        .RST          (SYNC_RST_1),
        .WrEn         (WrEn),
        .RdEn         (RdEn),
        .Address      (Addr),
        .WrData       (WrData),
        .RdData       (RdData),
        .RdData_Valid (RdData_Valid),
        .REG0         (REG0_OpA),
        .REG1         (REG1_OpB),
        .REG2         (REG2_UART_Config),
        .REG3         (REG3_Div_Ratio)
    );

    CLK_GATE u_Clock_Gating (
        .CLK       (REF_CLK),
        .CLK_EN    (CLK_EN),
//	.test_en   (test_mode),
        .GATED_CLK (ALU_CLK)
    );

    ALU_WRAPPER #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_ALU (
        .CLK       (ALU_CLK),
        .RST       (SYNC_RST_1),
        .A         (REG0_OpA),
        .B         (REG1_OpB),
        .ALU_FUN   (ALU_FUN),
        .Enable    (ALU_EN),
        .ALU_OUT   (ALU_OUT),
        .OUT_VALID (OUT_Valid)
    );

    // =========================================================================
    // Clock Domain 2 (UART_CLK Domain) & Clock Dividers
    // =========================================================================
    clk_div u_Clock_Divider_TX (
        .i_ref_clk   (UART_CLK),
        .i_rst_n     (SYNC_RST_2),
        .i_clk_en    (clk_div_en),               // Mandated supply tied to 1'b1
        .i_div_ratio (REG3_Div_Ratio[7:0]),
        .o_div_clk   (TX_CLK)
    );

    clk_div u_Clock_Divider_RX (
        .i_ref_clk   (UART_CLK),
        .i_rst_n     (SYNC_RST_2),
        .i_clk_en    (clk_div_en),               // Mandated supply tied to 1'b1
        .i_div_ratio (RX_Div_Ratio), // Prescale value used for RX Clocking
        .o_div_clk   (RX_CLK)
    );

    // =========================================================================
    // Domain Crossing FIFO & UART
    // =========================================================================
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_ASYNC_FIFO (
        .i_wclk   (REF_CLK),
        .i_rclk   (TX_CLK),
        .i_wrst_n (SYNC_RST_1),
        .i_rrst_n (SYNC_RST_2),
        .i_wr_en  (SYS_TX_D_VLD),
        .i_rd_en  (PULSE_GEN_RD_INC),
        .i_data   (SYS_TX_P_Data),
        .o_data   (FIFO_RD_DATA),
        .o_full   (FIFO_FULL),
        .o_empty  (FIFO_EMPTY)
    );

    pulse_gen u_PULSE_GEN (
        .CLK       (TX_CLK),
        .RST       (SYNC_RST_2),
        .in_sig    (TX_Busy),
        .pulse     (PULSE_GEN_RD_INC)
    );

    UART #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uart_inst (
        .RX_CLK(RX_CLK),
        .TX_CLK(TX_CLK),
        .RST(SYNC_RST_2),
        .prescale(REG2_UART_Config[7:2]),
        .Parity_Enable(REG2_UART_Config[0]),
        .Parity_Type(REG2_UART_Config[1]),
        .RX_IN(RX_IN),
        .RX_P_Data(RX_P_Data),
        .RX_D_VLD(RX_D_VLD),
        .par_err(PAR_ERR),
        .stp_err(STP_ERR),
        .TX_P_Data(FIFO_RD_DATA),
        .TX_D_VLD(~FIFO_EMPTY),
        .TX_OUT(TX_OUT),
        .busy(TX_Busy)
    );

endmodule
