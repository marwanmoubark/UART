`timescale 1ns / 1ps

module sys_top_tb();

    // -----------------------------------------------------------
    // Parameters & Timing
    // -----------------------------------------------------------
    localparam DATA_WIDTH = 8;
    localparam MEM_DEPTH  = 16;
    localparam ADDR_WIDTH = 4;

    localparam REF_CLK_PERIOD  = 20;            // 50 MHz
    localparam UART_CLK_PERIOD = 271.267;       // 3.6864 MHz
    localparam BIT_TIME        = 8680.55;       // 115200 baud

    // -----------------------------------------------------------
    // Signals
    // -----------------------------------------------------------
    logic REF_CLK;
    logic UART_CLK;
    logic RST;
    logic RX_IN;

    wire  TX_OUT;
    wire  PAR_ERR;
    wire  STP_ERR;

    // Received bytes and expected bytes (both filled in arrival order)
    bit [DATA_WIDTH-1:0] P_OUT_DATA[$];
    bit [DATA_WIDTH-1:0] expected_data_array[$];

    int errors = 0;

    // -----------------------------------------------------------
    // DUT
    // -----------------------------------------------------------
    sys_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .REF_CLK(REF_CLK),
        .UART_CLK(UART_CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .TX_OUT(TX_OUT),
        .PAR_ERR(PAR_ERR),
        .STP_ERR(STP_ERR)
    );

    // -----------------------------------------------------------
    // Clocks
    // -----------------------------------------------------------
    initial REF_CLK = 0;
    always #(REF_CLK_PERIOD/2.0) REF_CLK = ~REF_CLK;

    initial UART_CLK = 0;
    always #(UART_CLK_PERIOD/2.0) UART_CLK = ~UART_CLK;

    // -----------------------------------------------------------
    // Send one UART frame to the DUT (start, 8 data, even parity, stop, 1 idle)
    // -----------------------------------------------------------
    task send_uart_byte(input logic [7:0] data);
        begin
            RX_IN = 0;                          // start
            #(BIT_TIME);
            for (int i = 0; i < 8; i++) begin   // data, LSB first
                RX_IN = data[i];
                #(BIT_TIME);
            end
            RX_IN = ^data;                      // even parity
            #(BIT_TIME);
            RX_IN = 1;                          // stop
            #(BIT_TIME);
            #(BIT_TIME);                        // idle gap
        end
    endtask

    // -----------------------------------------------------------
    // Receive frames from the DUT (TX_OUT) and store them in P_OUT_DATA
    // -----------------------------------------------------------
    task deserialize();
        logic [7:0] shift_reg;
        bit expected_parity;
        begin
            forever begin
                @(negedge TX_OUT);                  // start bit edge
                #(BIT_TIME * 1.5);                  // middle of data bit 0

                for (int i = 0; i < 8; i++) begin   // sample data bits
                    shift_reg[i] = TX_OUT;
                    #(BIT_TIME);
                end

                if(DUT.uart_inst.Parity_Enable) begin
                    expected_parity = (DUT.uart_inst.Parity_Type) ? ~^shift_reg : ^shift_reg;
                    // now in the middle of the parity bit
                    if (TX_OUT !== expected_parity) begin
                        errors++;
                        $display("[%0t] [FAIL] TX parity wrong for 0x%02h", $time, shift_reg);
                    end
                    #(BIT_TIME);
                    // now in the middle of the stop bit
                end

                else begin
                    if (TX_OUT !== 1'b1) begin
                        errors++;
                        $display("[%0t] [FAIL] TX stop bit wrong for 0x%02h", $time, shift_reg);
                    end
                end

                P_OUT_DATA.push_back(shift_reg);
                $display("[%0t] [DESERIALIZER] Captured byte: 0x%02h", $time, shift_reg);
                // loop back and wait for the next start bit
            end
        end
    endtask

    // -----------------------------------------------------------
    // Wait until all expected bytes have arrived (or time out)
    // -----------------------------------------------------------
    task wait_for_responses();
        int waited;
        begin
            waited = 0;
            while (P_OUT_DATA.size() < expected_data_array.size() && waited < 100) begin
                #(BIT_TIME);
                waited++;
            end
            #(BIT_TIME * 2);    // small margin to catch any extra unexpected byte
        end
    endtask

    // -----------------------------------------------------------
    // Compare everything received against everything expected
    // -----------------------------------------------------------
    task check_expected_data();
        begin
            if (P_OUT_DATA.size() != expected_data_array.size()) begin
                errors++;
                $display("[%0t] [FAIL] Expected %0d bytes, received %0d bytes",
                         $time, expected_data_array.size(), P_OUT_DATA.size());
            end

            foreach (expected_data_array[i]) begin
                if (i < P_OUT_DATA.size()) begin
                    if (P_OUT_DATA[i] === expected_data_array[i])
                        $display("[PASS] byte %0d: expected 0x%02h, got 0x%02h",
                                 i, expected_data_array[i], P_OUT_DATA[i]);
                    else begin
                        errors++;
                        $display("[FAIL] byte %0d: expected 0x%02h, got 0x%02h",
                                 i, expected_data_array[i], P_OUT_DATA[i]);
                    end
                end
            end
        end
    endtask

    // -----------------------------------------------------------
    // Start the receiver after reset is released
    // -----------------------------------------------------------
    initial begin
        wait (RST === 1'b1);
        deserialize();
    end

    // -----------------------------------------------------------
    // Test sequence
    // -----------------------------------------------------------
    initial begin
        $display("==================================================");
        $display("               Starting Testbench                 ");
        $display("==================================================");

        // Reset
        RX_IN = 1;
        RST   = 0;
        #(REF_CLK_PERIOD * 10);
        RST   = 1;
        #(2000);                    // let both reset synchronizers release

        // Configuration
        $display("[%0t] Configuration", $time);
        send_uart_byte(8'hAA); send_uart_byte(8'h02); send_uart_byte(8'h81);  // REG2
        send_uart_byte(8'hAA); send_uart_byte(8'h03); send_uart_byte(8'h20);  // REG3

        //TEST 1: RegFile Write 0x55 -> addr 0x4
        $display("\n[%0t] TEST 1.0: RegFile Write", $time);
        send_uart_byte(8'hAA); send_uart_byte(8'h04); send_uart_byte(8'h55);

        $display("\n[%0t] TEST 1.1: RegFile Write @ 0xFF data 0x01", $time);
        send_uart_byte(8'hAA); send_uart_byte(8'h0F); send_uart_byte(8'h01);

        $display("\n[%0t] TEST 1.2: RegFile Write @ 0xF4 data 0x20", $time);
        send_uart_byte(8'hAA); send_uart_byte(8'h08); send_uart_byte(8'h20);

        $display("\n[%0t] TEST 1.3: RegFile Write @ 0xEF data 0xDD", $time);
        send_uart_byte(8'hAA); send_uart_byte(8'h0E); send_uart_byte(8'hDD);

        $display("\n[%0t] TEST 1.4: RegFile Write @ 0xA5 data 0x5A", $time);
        send_uart_byte(8'hAA); send_uart_byte(8'h07); send_uart_byte(8'h5A);


        //TEST 2: RegFile Read addr 0x4 -> expect 0x55
        $display("\n[%0t] TEST 2.0: RegFile Read @ 0x04 expect 0x55", $time);
        send_uart_byte(8'hBB); send_uart_byte(8'h04);
        expected_data_array.push_back(8'h55);
        wait_for_responses();

        $display("\n[%0t] TEST 2.1: RegFile Read @ 0xF4 expect 0x20", $time);
        send_uart_byte(8'hBB); send_uart_byte(8'h08);
        expected_data_array.push_back(8'h20);
        wait_for_responses();


        $display("\n[%0t] TEST 2.2: RegFile Read @ 0xA5 expect 0x5A", $time);
        send_uart_byte(8'hBB); send_uart_byte(8'h07);
        expected_data_array.push_back(8'h5A);
        wait_for_responses();

        $display("\n[%0t] TEST 2.3: RegFile Read @ 0xEF expect 0xDD", $time);
        send_uart_byte(8'hBB); send_uart_byte(8'h0E);
        expected_data_array.push_back(8'hDD);
        wait_for_responses();

        $display("\n[%0t] TEST 2.4: RegFile Read @ 0xFF expect 0x01", $time);
        send_uart_byte(8'hBB); send_uart_byte(8'h0F);
        expected_data_array.push_back(8'h01);
        wait_for_responses();


        // TEST 3: ALU with operands, 5 + 2 = 0x0007 (low byte first)
        $display("\n[%0t] TEST 3.0: ALU with operands (ADD) 8'h05 + 8'h02 = 8'h07", $time);
        send_uart_byte(8'hCC); send_uart_byte(8'h05); send_uart_byte(8'h02); send_uart_byte(8'h00);
        expected_data_array.push_back(8'h07);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();

         // TEST 4: ALU without operands, 5 - 2 = 0x0003
        $display("\n[%0t] TEST 3.1: ALU with operands (SUB) 8'h55 - 8'hFE = 8'h57", $time);
        send_uart_byte(8'hCC); send_uart_byte(8'h55); send_uart_byte(8'hFE); send_uart_byte(8'h01);
        expected_data_array.push_back(8'h57);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();


        $display("\n[%0t] TEST 3.2: ALU with operands (MUL) 8'sh81(-127) * 8'sh66(102) = 16'hCD66", $time);
        send_uart_byte(8'hCC); send_uart_byte(8'h81); send_uart_byte(8'h66); send_uart_byte(8'h02);
        expected_data_array.push_back(8'h66);   // low byte
        expected_data_array.push_back(8'hCD);   // high byte
        wait_for_responses();




        $display("\n[%0t] TEST 3.3: ALU with operands (DIV) 8'shFA(-6) / 8'h50(80) = 16'h0000", $time);
        send_uart_byte(8'hCC); send_uart_byte(8'hFA); send_uart_byte(8'h50); send_uart_byte(8'h03);
        expected_data_array.push_back(8'h00);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();


        // TEST 4: ALU without operands, 5 - 2 = 0x0003
        $display("\n[%0t] TEST 4.0: ALU without operands (CMP) 8'hFA == 8'h50 = 8'h00", $time);
        send_uart_byte(8'hDD); send_uart_byte(8'h09);
        expected_data_array.push_back(8'h00);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();

        $display("\n[%0t] TEST 4.1: ALU without operands (SHF) 8'hFA >> 1 = 8'h7D", $time);
        send_uart_byte(8'hDD); send_uart_byte(8'h0C);
        expected_data_array.push_back(8'h7D);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();

        $display("\n[%0t] TEST 4.2: ALU without operands (SHF) 8'h50 << 1 = 8'hA0", $time);
        send_uart_byte(8'hDD); send_uart_byte(8'h0C);
        expected_data_array.push_back(8'hA0);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();

        $display("\n[%0t] TEST 4.3: ALU without operands (LOGIC) 8'h50 & 8'hFA = 8'h50", $time);
        send_uart_byte(8'hDD); send_uart_byte(8'h04);
        expected_data_array.push_back(8'h50);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();

        $display("\n[%0t] TEST 4.4: ALU without operands (LOGIC) 8'h50 NOR 8'hFA = 8'h05", $time);
        send_uart_byte(8'hDD); send_uart_byte(8'h07);
        expected_data_array.push_back(8'h05);   // low byte
        expected_data_array.push_back(8'h00);   // high byte
        wait_for_responses();



       

        // Result
        $display("\n==================================================");
        check_expected_data();
        if (PAR_ERR !== 1'b0 || STP_ERR !== 1'b0) begin
            errors++;
            $display("[FAIL] PAR_ERR=%b STP_ERR=%b", PAR_ERR, STP_ERR);
        end
        if (errors == 0) $display("TEST PASSED");
        else             $display("TEST FAILED: %0d errors", errors);
        $display("==================================================");
        $finish;
    end

    // Watchdog
    initial begin
        #50_000_000;
        $display("TIMEOUT");
        $finish;
    end

endmodule