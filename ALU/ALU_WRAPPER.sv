module ALU_WRAPPER #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  CLK,
    input  wire                  RST,
    input  wire [DATA_WIDTH-1:0] A,
    input  wire [DATA_WIDTH-1:0] B,
    input  wire [3:0]            ALU_FUN,
    input  wire                  Enable,
    output wire [15:0]           ALU_OUT,
    output wire                  OUT_VALID
);

    // Internal signals from ALU_TOP
    wire arith_flag, logic_flag, shift_flag, cmp_flag;
    wire signed [(2 * DATA_WIDTH) - 1 : 0] arith_out;
    wire [DATA_WIDTH - 1 : 0] logic_out, cmp_out, shift_out;

    // Instantiate the original ALU_TOP with 16-bit Data_Width
    ALU_TOP #(
        .Data_Width(DATA_WIDTH)
    ) alu_top_inst (
        .A          (A),
        .B          (B),
        .RST        (RST),
        .CLK        (CLK),
        .ALU_FUN    (ALU_FUN),
        .arith_flag (arith_flag),
        .logic_flag (logic_flag),
        .shift_flag (shift_flag),
        .cmp_flag   (cmp_flag),
        .arith_out  (arith_out),
        .logic_out  (logic_out),
        .cmp_out    (cmp_out),
        .shift_out  (shift_out)
    );

    // Mux the appropriate output based on ALU_FUN
    // ALU_FUN[3:2] determines the operation type:
    // 00: Arithmetic, 01: Logic, 10: Compare, 11: Shift
    reg [15:0] alu_out_reg;
    reg        out_valid_reg;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            alu_out_reg   <= 16'h0;
            out_valid_reg <= 1'b0;
        end else if (Enable) begin
            out_valid_reg <= 1'b1;
            case (ALU_FUN[3:2])
                2'b00: alu_out_reg <= arith_out;  // Arithmetic
                2'b01: alu_out_reg <= {8'h00, logic_out};  // Logic
                2'b10: alu_out_reg <= {8'h00, cmp_out};    // Compare
                2'b11: alu_out_reg <= {8'h00, shift_out};  // Shift
                default: alu_out_reg <= 16'h0;
            endcase
        end else begin
            out_valid_reg <= 1'b0;
        end
    end

    assign ALU_OUT   = alu_out_reg;
    assign OUT_VALID = out_valid_reg;

endmodule
