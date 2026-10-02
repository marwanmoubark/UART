module RX_SAMPLER #(
    parameter DATA_WIDTH = 8,
    parameter num_bits = $clog2(DATA_WIDTH)
)(
    input  wire        CLK, RST,
    input  wire [5:0]  prescale,
    input  wire        RX_IN,
    input  wire        data_sample_en,
    input  wire [7:0]  edge_cnt,
    output reg         sampled_bit
);

wire [7:0] mid_edge = prescale / 2;

wire region_0 = data_sample_en && (edge_cnt == mid_edge - 1);
wire region_1 = data_sample_en && (edge_cnt == mid_edge);
wire region_2 = data_sample_en && (edge_cnt == mid_edge + 1);

reg s0, s1;   // captured samples from the first two regions

// store the first two samples as we pass through their regions
always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        s0 <= 1'b0;
        s1 <= 1'b0;
    end else begin
        if (region_0) s0 <= RX_IN;
        if (region_1) s1 <= RX_IN;
    end
end

always @(*) begin
    sampled_bit = 1'b0;
    if (region_2)
        sampled_bit = (s0 & s1) | (s1 & RX_IN) | (s0 & RX_IN);
end

endmodule
