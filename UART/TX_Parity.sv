module TX_Parity #(
    parameter DATA_WIDTH = 8
)(
    input CLK, RST,
    input [DATA_WIDTH-1:0] data_in,
    input busy, data_valid, parity_type,
    output reg parity_bit
);

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            parity_bit <= 1'b0;
        end
        // Calculate parity directly from input data at the moment data_valid is accepted
        else if (data_valid && !busy) begin
            parity_bit <= parity_type ? ~^data_in : ^data_in;
        end
    end

endmodule