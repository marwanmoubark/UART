`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2025 07:01:52 PM
// Design Name: 
// Module Name: UART_rx
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


module UART_rx #(parameter F_sys = 50000000, parameter oversample = 8)
(
    input clk, rx, reset_n, CPU_read, 
    input [3:0] baud_rate,           
    output[7:0] data_out,
    output BCLK_RX,   
    output fifo_empty, fifo_full 
);

    
    wire    [7:0] rx_data   ;
    wire    rx_valid        ;
    wire    baud_rx         ;



assign BCLK_RX = baud_rx;



baud_gen #(
    .F_sys 	(50000000  ))
u_baud_gen(
    .baud_rate 	(baud_rate  ),
    .clk       	(clk        ),
    .reset_n   	(reset_n    ),
    .baud_tx   	(  ),
    .baud_rx   	(baud_rx   )
);


    FSM_RX #(.oversample(oversample)) fsm_rx_inst (
        .rx_data(rx),       
        .Bclk(baud_rx),     
        .reset_n(reset_n),
        .rx_valid(rx_valid),
        .data_out(rx_data)
    );

    FIFO FIFO_rx_inst (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(rx_data),
    .write_en(rx_valid),
    .data_out(data_out),
    .read_en(CPU_read),
    .data_valid(data_valid), 
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty)
);
endmodule

