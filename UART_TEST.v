`timescale 1ns / 1ps

module UART_System_TB();

    localparam CLK_PERIOD = 20; // 50 MHz
    localparam NUM_WORDS  = 8;  // FIFO depth for testing

    reg clk, reset_n;
    reg [7:0] data_mem [0:NUM_WORDS-1];  // stimulus data storage
    reg [7:0] rx_mem   [0:NUM_WORDS-1];  // received data storage

    integer i;

    // DUT A <-> DUT B connections
    wire tx_a, rx_a, tx_b, rx_b;
    assign rx_a = tx_b;  // cross connect
    assign rx_b = tx_a;

    // CPU interfaces
    reg        cpu_wr_a, cpu_rd_a;
    reg [7:0]  cpu_data_in_a;
    wire [7:0] cpu_data_out_a;
    wire       TX_full_A, TX_empty_A, RX_full_A, RX_empty_A;

    reg        cpu_wr_b, cpu_rd_b;
    reg [7:0]  cpu_data_in_b;
    wire [7:0] cpu_data_out_b;
    wire       TX_full_B, TX_empty_B, RX_full_B, RX_empty_B;
    wire BCLK_TX , BCLK_RX;

    reg [3:0] baud_rate;

    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    // DUT A (transmitter side)
    UART_top_module DUT_A (
        .clk(clk), .reset_n(reset_n),
        .CPU_write(cpu_wr_a), .CPU_read(cpu_rd_a),
        .data_in(cpu_data_in_a), .data_out(cpu_data_out_a),
        .baud_rate(baud_rate),
        .rx_pin(rx_a), .tx_pin(tx_a),
        .TX_full(TX_full_A), .TX_empty(TX_empty_A),
        .RX_full(RX_full_A), .RX_empty(RX_empty_A),
        .BCLK_TX(BCLK_TX), .BCLK_RX(BCLK_RX)
    );

    // DUT B (receiver side)
    UART_top_module DUT_B (
        .clk(clk), .reset_n(reset_n),
        .CPU_write(cpu_wr_b), .CPU_read(cpu_rd_b),
        .data_in(cpu_data_in_b), .data_out(cpu_data_out_b),
        .baud_rate(baud_rate),
        .rx_pin(rx_b), .tx_pin(tx_b),
        .TX_full(TX_full_B), .TX_empty(TX_empty_B),
        .RX_full(RX_full_B), .RX_empty(RX_empty_B),
        .BCLK_TX(), .BCLK_RX()
    );

    initial begin
        reset_n = 0;
        cpu_wr_a = 0; cpu_rd_a = 0; cpu_data_in_a = 8'h00;
        cpu_wr_b = 0; cpu_rd_b = 0; cpu_data_in_b = 8'h00;
        baud_rate = 4'b0111;

        // preload stimulus data
        data_mem[0] = 8'h55;
        data_mem[1] = 8'h4E;
        data_mem[2] = 8'hF0;
        data_mem[3] = 8'hFF;
        data_mem[4] = 8'h00;
        data_mem[5] = $random;
        data_mem[6] = $random;
        data_mem[7] = $random;

        #(10*CLK_PERIOD);
        reset_n = 1;

        // push all words into Device A TX FIFO
        for (i = 0; i < NUM_WORDS; i = i+1) begin
            @(negedge clk);
            cpu_data_in_a = data_mem[i];
            cpu_wr_a = 1;
            @(negedge clk);
            cpu_wr_a = 0;
            // wait some time before next write (UART frame length)
            #(15000*CLK_PERIOD);
        end

        // Wait until DUT A finishes transmitting
        wait (TX_empty_A);

        // Read back all words from Device B RX FIFO
        for (i = 0; i < NUM_WORDS; i = i+1) begin
            @(negedge clk);
            cpu_rd_b = 1;
            @(negedge clk);
            rx_mem[i] = cpu_data_out_b;
            cpu_rd_b = 0;
            #(1000*CLK_PERIOD);
        end

        // Compare sent vs received
        // Compare sent vs received word by word
        for (i = 0; i < NUM_WORDS; i = i+1) begin
            if (data_mem[i] === rx_mem[i]) begin
                $display("PASS : data_in_a[%0d] = 0x%0h , data_out_b[%0d] = 0x%0h",
                          i, data_mem[i], i, rx_mem[i]);
            end else begin
                $display("FAIL : data_in_a[%0d] = 0x%0h , data_out_b[%0d] = 0x%0h",
                          i, data_mem[i], i, rx_mem[i]);
            end
        end

        $display("TCL_OK: UART communication successful, all %0d words matched!", NUM_WORDS);
        $finish;
    end

endmodule
