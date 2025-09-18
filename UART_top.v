`timescale 1ns / 1ps

module UART_top_module
#(parameter F_sys = 50_000_000 , oversample = 8)
(
    input clk , reset_n , CPU_write , CPU_read ,
    input [7:0]data_in , 
    input [3:0] baud_rate ,
    input  rx_pin,
    output RX_full , RX_empty ,
    output TX_full , TX_empty ,
    output tx_pin,
    output BCLK_TX, BCLK_RX,
    output [7:0] data_out 
);


    UART_TX UART_TX_INST(
        .data_in    (data_in    ),
        .clk        (clk        ),
        .reset_n    (reset_n    ),
        .baud_rate  (baud_rate  ),
        .CPU_write  (CPU_write  ),
        .fifo_empty (TX_empty   ),
        .fifo_full  (TX_full    ),
        .BCLK_TX    (BCLK_TX),
        .tx_data    (tx_pin     )
    );

    UART_rx #(.oversample(oversample)) 
    UART_rx_INST(
        .clk        (clk        ),
        .rx         (rx_pin     ),
        .baud_rate  (baud_rate  ),
        .reset_n    (reset_n    ),
        .CPU_read   (CPU_read   ),
        .fifo_empty (RX_empty   ),
        .fifo_full  (RX_full    ),
        .BCLK_RX    (BCLK_RX),
        .data_out   (data_out   )

    );

endmodule
