`timescale 1ns / 1ps

module UART_top_module_TB();


    localparam CLK_PERIOD = 20; // 20ns = 50 MHz

    reg clk, reset_n;
    reg CPU_write, CPU_read;
    reg [7:0] data_in;
    wire [7:0] data_out;
    reg [3:0] baud_rate;
    wire rx_pin; 
    wire tx_pin;
    wire TX_full, TX_empty ;
    wire RX_full, RX_empty ;
    wire BCLK_TX , BCLK_RX ;




assign rx_pin = tx_pin ;

    UART_top_module uut (
        .clk(clk),
        .reset_n(reset_n),
        .CPU_write(CPU_write),
        .CPU_read(CPU_read),
        .data_in(data_in),
        .data_out(data_out),
        .baud_rate(baud_rate),
        .rx_pin(rx_pin),       
        .tx_pin(tx_pin),
        .TX_full(TX_full),
        .TX_empty(TX_empty),
        .RX_full(RX_full),
        .BCLK_RX(BCLK_RX),
        .BCLK_TX(BCLK_TX),
        .RX_empty(RX_empty)
    );


    integer i;
    always begin

        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end
        
       initial begin
        reset_n = 0;
        CPU_write = 0;
        CPU_read = 0 ;
        data_in = 8'h00;
        baud_rate = 4'b0111;
        #100;
        
        reset_n = 1; 

        #200000;

        data_in = 8'b01010101;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        
        
        data_in = 8'b01001110;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        
        
        data_in = 8'b11110000;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        
        
        data_in = 8'b11111111;
        CPU_write = 1;
        #20;
        CPU_write = 0;
       #(15000*CLK_PERIOD);
        
        
        data_in = 8'b00000000;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        
        data_in = $random;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        
        data_in = $random;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        
        data_in = $random;
        CPU_write = 1;
        #20;
        CPU_write = 0;
         #(15000*CLK_PERIOD);
        
        data_in = $random;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        

        data_in = $random;
        CPU_write = 1;
        #20;
        CPU_write = 0;
        #(15000*CLK_PERIOD);
        
        
        
        wait(TX_empty);
        #20000;
            
            
       
        #(15000*CLK_PERIOD);
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        ////first///////////
         #(15000*CLK_PERIOD);
        
            
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        /////second/////////
         #(15000*CLK_PERIOD);
            
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        ///3rd///////
        #(15000*CLK_PERIOD);
            
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        ////4th/////
        #(15000*CLK_PERIOD);
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        /////////5th///////////
        #(15000*CLK_PERIOD);
            
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        ////////6th///////////
         #(15000*CLK_PERIOD);
            
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        //////////7th////////////
        #(15000*CLK_PERIOD);
            
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
        ///////////////8th/////////////
        #(15000*CLK_PERIOD); 
        CPU_read = 1;
        #(CLK_PERIOD);
        CPU_read = 0;
        #(CLK_PERIOD * 2);
            

        #200000;
        $finish;
    end

endmodule