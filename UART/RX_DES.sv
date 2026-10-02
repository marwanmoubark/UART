module RX_DES #(
    parameter DATA_WIDTH = 8,
    parameter num_bits = $clog2(DATA_WIDTH)
)(
    input CLK , RST ,
    input wire sampled_bit,
    input wire deser_en,
    input wire data_valid,
    input wire [num_bits:0] bit_cnt,
    output reg [DATA_WIDTH-1:0] P_Data , shift_reg
);

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        P_Data <= {DATA_WIDTH{1'b0}};
        shift_reg <= {DATA_WIDTH{1'b0}};
    end
    else begin 
        if (deser_en) begin
            shift_reg[bit_cnt -1] <= sampled_bit;
        end
        else if(data_valid) begin
            P_Data <= shift_reg;
            shift_reg <= {DATA_WIDTH{1'b0}};
        end
    end
end
endmodule