module UART #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  RX_CLK,
    input  wire                  TX_CLK,
    input  wire                  RST,  // Active-low asynchronous reset

    // Configuration / Control
    input  wire [5:0]            prescale,
    input  wire                  Parity_Enable,
    input  wire                  Parity_Type,

    // Receiver Interface
    input  wire                  RX_IN,
    output wire [DATA_WIDTH-1:0] RX_P_Data,
    output wire                  RX_D_VLD,
    output wire                  par_err,
    output wire                  stp_err,

    // Transmitter Interface
    input  wire [DATA_WIDTH-1:0] TX_P_Data,
    input  wire                  TX_D_VLD,
    output wire                  TX_OUT,
    output wire                  busy
);

    // Instantiate RX Subsystem
    RX_TOP #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_UART_RX_Top (
        .CLK(RX_CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .Parity_Type(Parity_Type),
        .Parity_Enable(Parity_Enable),
        .prescale(prescale),
        .data_valid(RX_D_VLD),
        .par_err(par_err),
        .stp_err(stp_err),
        .P_Data(RX_P_Data)
    );

    // Instantiate TX Subsystem
    TX_TOP #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_TX_TOP (
        .CLK(TX_CLK),
        .RST(RST),
        .data_in(TX_P_Data),
        .data_valid(TX_D_VLD),
        .parity_enable(Parity_Enable),
        .parity_type(Parity_Type),
        .Data_Out(TX_OUT),
        .busy(busy)
    );

endmodule