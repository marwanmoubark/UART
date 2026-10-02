module TX_FSM #(
    parameter DATA_WIDTH = 8
)(
    input CLK, RST,
    input data_valid, parity_enable, ser_done,
    output reg [2:0] mux_sel,
    output reg busy, ser_enable
);

    typedef enum reg [2:0] {
        IDLE   = 3'b000, 
        START  = 3'b001,
        DATA   = 3'b011,
        PARITY = 3'b010,
        STOP   = 3'b110
    } state_t;

    state_t cs, ns;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            cs   <= IDLE;
            busy <= 1'b0;
        end else begin
            cs   <= ns;
            busy <= (ns != IDLE); // busy is high for all non-IDLE states
        end
    end

    always @(*) begin
        case (cs)
            IDLE: begin
                mux_sel    = 3'b100; // Idle line (HIGH)
                ser_enable = 1'b0;   // Keep serializer disabled in IDLE
                if (data_valid)
                    ns = START;
                else
                    ns = IDLE;
            end

            START: begin
                ns         = DATA;
                mux_sel    = 3'b000; // Start bit (LOW)
                ser_enable = 1'b1;   // Enable shifting starting next cycle
            end

            DATA: begin
                mux_sel    = 3'b010; // Serial data bit
                ser_enable = 1'b1;
                if (ser_done) begin
                    ser_enable = 1'b0;
                    ns         = parity_enable ? PARITY : STOP;
                end else begin
                    ns         = DATA;
                end
            end

            PARITY: begin
                ns         = STOP;
                mux_sel    = 3'b011; // Parity bit
                ser_enable = 1'b0;
            end

            STOP: begin
                ns         = IDLE;
                mux_sel    = 3'b001; // Stop bit (HIGH)
                ser_enable = 1'b0;
            end

            default: begin
                ns         = IDLE;
                mux_sel    = 3'b100;
                ser_enable = 1'b0;
            end
        endcase
    end

endmodule