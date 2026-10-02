module TX_SER #(
    parameter DATA_WIDTH = 8
)(
    input CLK, RST,
    input [DATA_WIDTH-1:0] data_in,
    input data_valid, busy, ser_Enable,
    output reg ser_done,
    output reg ser_data
);

    reg [DATA_WIDTH-1:0] shift_reg;
    reg [3:0] bit_cnt;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            shift_reg <= '0;
            ser_data  <= 1'b1; // UART Idle line is HIGH
            bit_cnt   <= '0;
            ser_done  <= 1'b0;
        end
        // 1. Direct capture from primary input bus when idle/ready
        else if (data_valid && !busy) begin
            shift_reg <= data_in;
            bit_cnt   <= '0;
            ser_done  <= 1'b0;
            ser_data  <= 1'b1;
        end
        // 2. Active shifting during DATA state (busy is 1, so data_valid is ignored)
        else if (ser_Enable && !ser_done) begin
            ser_data  <= shift_reg[0];
            shift_reg <= {1'b0, shift_reg[DATA_WIDTH-1:1]};
            bit_cnt   <= bit_cnt + 1'b1;
            
            if (bit_cnt == DATA_WIDTH - 1) begin
                ser_done <= 1'b1;
            end
        end
        else if (ser_done) begin
            ser_data <= 1'b1;
        end
    end

endmodule