module TX_MUX #(
    parameter DATA_WIDTH = 8
)(
    input ser_data,parity_bit,
    input [2:0] sel,
    input CLK , RST,
    output reg Data_Out
);

reg Data_Out_Comp;

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        Data_Out <= 1'b1;
    end else begin
        Data_Out <= Data_Out_Comp; // Example logic for multiplexing
    end
end

always @(*) begin
    case(sel)
        3'b000: Data_Out_Comp = 1'b0; // Select start bit
        3'b001: Data_Out_Comp = 1'b1; // Select stop bit
        3'b010: Data_Out_Comp = ser_data; // Select serial data
        3'b011: Data_Out_Comp = parity_bit; // Select parity bit 
        3'b100: Data_Out_Comp = 1'b1; // Select idle state
        default: Data_Out_Comp = 1'b1; // Default case
    endcase
end
endmodule