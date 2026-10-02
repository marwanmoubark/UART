module SYS_CTRL #(
    parameter DATA_WIDTH = 8,
    parameter MEM_DEPTH  = 16,
    parameter ADDR_WIDTH = $clog2(MEM_DEPTH)

)(
    // Inputs
    input  wire [2*DATA_WIDTH-1:0] ALU_OUT,
    input  wire                    OUT_Valid,
    input  wire [DATA_WIDTH-1:0]   RX_P_Data,
    input  wire                    RX_D_VLD,
    input  wire [DATA_WIDTH-1:0]   RdData,
    input  wire                    RdData_Valid,
    input  wire                    CLK,
    input  wire                    RST,
    input  wire                    FIFO_FULL,

    // Outputs
    output wire                    ALU_EN,
    output wire [3:0]              ALU_FUN,     // assuming 4-bit function select
    output wire                    CLK_EN,
    output wire [ADDR_WIDTH-1:0]   Addr,
    output wire                    WrEN,
    output wire                    RdEn,
    output wire [DATA_WIDTH-1:0]   WrData,
    output wire [DATA_WIDTH-1:0]   TX_P_Data,
    output wire                    TX_D_VLD,
    output wire                    clk_div_en
);

    // Module internal registers
    reg [ADDR_WIDTH-1:0] Addr_d   , Addr_q;
    reg [DATA_WIDTH-1:0] WrData_d , WrData_q;
    reg [DATA_WIDTH-1:0] RdData_d , RdData_q;
    reg [3:0]            ALU_FUN_d, ALU_FUN_q;

    // FSM encoding (RD_ADDR removed - was unreachable/dead state)
    typedef enum reg [3:0] {
        IDLE        = 4'b0000,  // 0
        WR_ADDR     = 4'b0011,  // 3
        WR_DATA     = 4'b0010,  // 2
        READ        = 4'b0110,  // 6
        FIFO        = 4'b0111,  // 7
        WR_A        = 4'b0101,  // 5
        WR_B        = 4'b0100,  // 4
        WR_FUN      = 4'b1100,  // 12
        RD_ALU_LOW  = 4'b1101,  // 13
        RD_ALU_HIGH = 4'b0001,
        XAA         = 4'b1111,  // 15
        XBB         = 4'b1110,  // 14
        XCC         = 4'b1010,  // 10
        XDD         = 4'b1011   // 11
    } state_t;

    state_t CS, NS;

    // FSM State Register
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            CS <= IDLE;
        end
        else begin
            CS <= NS;
        end
    end

    // Next State Logic and Data-Capture Logic
    always @(*) begin
        // Default assignments (prevents latch inference)
        NS        = CS;
        Addr_d    = Addr_q;
        WrData_d  = WrData_q;
        RdData_d  = RdData_q;
        ALU_FUN_d = ALU_FUN_q;

        case (CS)

            IDLE: begin
                if (RX_D_VLD) begin
                    case (RX_P_Data)
                        8'hAA   : NS = XAA;
                        8'hBB   : NS = XBB;
                        8'hCC   : NS = XCC;
                        8'hDD   : NS = XDD;
                        default : NS = IDLE;
                    endcase
                end
            end

            // ---------------- RF Write path (CMD -> Addr -> Data -> pulse) ----------------
            XAA: begin
                if (RX_D_VLD) begin
                    NS     = WR_ADDR;
                    Addr_d = RX_P_Data;
                end
            end

            WR_ADDR: begin
                if (RX_D_VLD) begin
                    NS       = WR_DATA;
                    WrData_d = RX_P_Data;
                end
            end

            WR_DATA: begin
                // Addr_q / WrData_q are stable here -> WrEN pulses in this state
                NS = IDLE;
            end

            // ---------------- RF Read path (CMD -> Addr -> pulse+wait) ----------------
            XBB: begin
                if (RX_D_VLD) begin
                    Addr_d = RX_P_Data;
                    NS     = READ;
                end
            end

            READ: begin
                // Addr_q is stable here -> RdEn pulses in this state
                if (RdData_Valid) begin
                    NS      = FIFO;
                    RdData_d = RdData;
                end
            end

            FIFO: begin
                if (!FIFO_FULL) begin
                    NS = IDLE;
                end
            end

            // ---------------- ALU op w/ operands path (CMD -> OpA -> OpB -> FUN) ----------------
            XCC: begin
                // This byte is Operand A -> stage it for address 0
                if (RX_D_VLD) begin
                    WrData_d = RX_P_Data;
                    Addr_d   = 'd0;
                    NS       = WR_A;
                end
            end

            WR_A: begin
                // Addr_q/WrData_q now hold Operand A @ addr0 -> WrEN pulses in this state.
                // This byte is Operand B -> stage it for address 1
                if (RX_D_VLD) begin
                    WrData_d = RX_P_Data;
                    Addr_d   = 'd1;
                    NS       = WR_B;
                end
            end

            WR_B: begin
                // Addr_q/WrData_q now hold Operand B @ addr1 -> WrEN pulses in this state.
                // This byte is the ALU function select
                if (RX_D_VLD) begin
                    ALU_FUN_d = RX_P_Data[3:0];
                    NS        = WR_FUN;
                end
            end

            WR_FUN: begin
                // ALU_EN pulses in this state (ALU_FUN_q already stable)
                if (OUT_Valid)
                    NS = RD_ALU_LOW;
                
            end

            RD_ALU_LOW: begin
                RdData_d = ALU_OUT[DATA_WIDTH-1:0]; // Capture lower byte
                if (!FIFO_FULL) begin
                    NS = RD_ALU_HIGH; // Move to high byte after low byte is sent
                end
            end

            RD_ALU_HIGH: begin
                RdData_d = ALU_OUT[2*DATA_WIDTH-1:DATA_WIDTH]; // Capture upper byte
                if (!FIFO_FULL) begin
                    NS = FIFO;
                end
            end

            XDD: begin
                if (RX_D_VLD) begin
                    ALU_FUN_d = RX_P_Data[3:0];
                    NS        = WR_FUN;
                end else NS = XDD; // stay in XDD until RX_D_VLD is high
            end

            default: NS = IDLE;
        endcase
    end

    // ---------------- Output Continuous Assignments ----------------
    assign WrEN      = (CS == WR_DATA) || (CS == WR_A) || (CS == WR_B);
    assign RdEn      = (CS == READ);
    assign TX_D_VLD = ((CS == RD_ALU_HIGH) || (CS == FIFO)) && !FIFO_FULL;
    assign ALU_EN    = (CS == WR_FUN);
    assign Addr      = Addr_q;
    assign WrData    = WrData_q;
    assign TX_P_Data = RdData_q;
    assign ALU_FUN   = ALU_FUN_q;
    assign CLK_EN    = (CS == WR_B) || (CS == WR_FUN) || (CS == RD_ALU_LOW) || (CS == RD_ALU_HIGH) || (CS == XDD);
    assign clk_div_en = 1'b1;

    // Internal Data Registers
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            Addr_q    <= 'd0;
            WrData_q  <= 'd0;
            RdData_q  <= 'd0;
            ALU_FUN_q <= 'd0;
        end
        else begin
            Addr_q    <= Addr_d;
            WrData_q  <= WrData_d;
            RdData_q  <= RdData_d;
            ALU_FUN_q <= ALU_FUN_d;
        end
    end

endmodule