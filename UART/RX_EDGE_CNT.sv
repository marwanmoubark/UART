module RX_EDGE_CNT #(
    parameter DATA_WIDTH = 8,
    parameter num_bits = $clog2(DATA_WIDTH)
)(
    input wire CLK , RST,
    input wire [5:0] prescale,
    input wire edge_cnt_en,
    output reg [7:0] edge_cnt,
    output reg [num_bits : 0] bit_cnt
);

always @(posedge CLK or negedge RST) begin 
    if (!RST) begin
        edge_cnt <= 'd0;
    end 
    else if (edge_cnt_en && edge_cnt != ({2'b00,prescale - 1})) begin
        edge_cnt <= edge_cnt + 1;
    end
    else edge_cnt <= 'd0;
end

always @(posedge CLK or negedge RST) begin 
    if (!RST) begin
        bit_cnt <= 'd0;
    end 
    else if (edge_cnt_en == 1'b1 && bit_cnt != (DATA_WIDTH + 1)) begin
        if (edge_cnt == prescale - 1) begin
            bit_cnt <= bit_cnt + 1;
        end
    end
    else bit_cnt <= 'd0;
end

endmodule