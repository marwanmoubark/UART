module UART_TX # (parameter F_sys = 50_000_000 )(
    input clk, reset_n, CPU_write,
    input [7:0] data_in,
    input [3:0] baud_rate,
    output BCLK_TX,
    output tx_data, fifo_full, fifo_empty 
);

wire        tx_start_fifo   ;
wire        [7:0]tx_data_in ;
wire        baud_tx         ;
wire        tx_busy         ;



assign BCLK_TX = baud_tx;




baud_gen #(
    .F_sys 	(F_sys ))
u_baud_gen(
    .baud_rate 	(baud_rate  ),
    .clk       	(clk        ),
    .reset_n   	(reset_n    ),
    .baud_tx   	(baud_tx    ),
    .baud_rx   	(           )
);

FSM_tx FSM_tx_inst(
    .Bclk        	(baud_tx      ),
    .reset_n     	(reset_n      ),
    .tx_start    	(tx_start_fifo),
    .data_in     	(tx_data_in   ),
    .tx_busy        (       tx_busy      ),
    .tx_data     	(tx_data      )
);

FIFO FIFO_tx_inst (
    .clk(clk),
    .reset_n(reset_n            ),
    .data_in(data_in            ),
    .write_en(CPU_write         ),
    .read_en(~tx_busy           ),
    .data_out(tx_data_in        ),
    .data_valid(tx_start_fifo   ),  
    .fifo_full(fifo_full        ),
    .fifo_empty(fifo_empty      )
);

endmodule