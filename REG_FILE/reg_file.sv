module reg_file #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter MEM_DEPTH  = 8
)(
    input  wire                  CLK,
    input  wire                  RST,            // Active Low Synchronized Reset
    input  wire                  WrEn,
    input  wire                  RdEn,
    input  wire [ADDR_WIDTH-1:0] Address,
    input  wire [DATA_WIDTH-1:0] WrData,
    
    output reg  [DATA_WIDTH-1:0] RdData,
    output reg                   RdData_Valid,
    
    // Dedicated Outputs for Configs and ALU Operands
    output wire [DATA_WIDTH-1:0] REG0,           // Address 0x0: Operand A
    output wire [DATA_WIDTH-1:0] REG1,           // Address 0x1: Operand B
    output wire [DATA_WIDTH-1:0] REG2,           // Address 0x2: UART Config
    output wire [DATA_WIDTH-1:0] REG3            // Address 0x3: Division Ratio
);

    // 8x16 Register File Memory
    reg [15:0] reg_mem [0:MEM_DEPTH-1];
    integer i;

    // Direct continuous assignments for dedicated outputs (Truncated/Sliced to DATA_WIDTH)
    assign REG0 = reg_mem[0][DATA_WIDTH-1:0];
    assign REG1 = reg_mem[1][DATA_WIDTH-1:0];
    assign REG2 = reg_mem[2][DATA_WIDTH-1:0];
    assign REG3 = reg_mem[3][DATA_WIDTH-1:0];

    // =========================================================================
    // Write & Read Logic
    // =========================================================================
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            // Reset state defaults according to specifications
            reg_mem[0]   <= 16'h0000;
            reg_mem[1]   <= 16'h0000;
            reg_mem[2]   <= 16'h0081; // REG2[0]=1 (Parity EN), REG2[1]=0 (Even), REG2[7:2]=32 (Prescale)
            reg_mem[3]   <= 16'h0020; // REG3[7:0]=32 (Div Ratio)
            
            for (i = 4; i < MEM_DEPTH; i = i + 1) begin
                reg_mem[i] <= 16'h0000;
            end

            RdData       <= 'b0;
            RdData_Valid <= 1'b0;
        end
        else begin
            // Default read valid flag
            RdData_Valid <= 1'b0;

            // Write Operation
            if (WrEn && !RdEn) begin
                reg_mem[Address] <= {{(16-DATA_WIDTH){1'b0}}, WrData};
            end
            
            // Read Operation
            else if (RdEn && !WrEn) begin
                RdData       <= reg_mem[Address][DATA_WIDTH-1:0];
                RdData_Valid <= 1'b1;
            end
        end
    end

endmodule