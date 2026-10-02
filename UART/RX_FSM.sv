module RX_FSM #(
    parameter DATA_WIDTH = 8,
    parameter num_bits = $clog2(DATA_WIDTH)
)(
    input  wire CLK, RST,
    input  wire RX_IN,
    input  wire                parity_en,
    input  wire [5:0]          prescale,
    input  wire [7:0]          edge_cnt, 
    input  wire [num_bits:0] bit_cnt,
    input  wire                stop_err, start_glitch, par_err,

    output reg  data_valid,
    output reg  data_sample_en, edge_cnt_en, 
    output reg  stop_chk_en, start_chk_en,
    output reg  par_chk_en, deser_en , data_valid_comp,
    output wire smpl_pulse          // NEW: 1-cycle pulse at the sample instant
);

// Grey-ish encoding for RX FSM
typedef enum reg [2:0] {
    IDLE   = 3'b000,
    START  = 3'b001,
    READ   = 3'b011,
    PARITY = 3'b010,
    STOP   = 3'b110
} state_t;

state_t cs, ns;                 // Current / next state

wire [7:0] sampling_edge = prescale / 2;

reg data_invalid;

// ---------------------------------------------------------------
// Shared sampling-window detection, reused by START / PARITY / STOP
// instead of being re-derived three separate times.
// ---------------------------------------------------------------
wire in_sample_window =  (edge_cnt == sampling_edge - 1) ||
                         (edge_cnt == sampling_edge)     ||
                         (edge_cnt == sampling_edge + 1);

wire sample_confirmed  = (edge_cnt == sampling_edge + 1);

// ---------------------------------------------------------------
// State register
// ---------------------------------------------------------------
always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        cs         <= IDLE;
        data_valid <= 1'b0;
    end else begin
        cs         <= ns;
        data_valid <= data_valid_comp;
    end
end

// ---------------------------------------------------------------
// Next-state / output logic
// ---------------------------------------------------------------
always @(*) begin
    // Defaults every state, avoids inferred latches
    data_sample_en  = 1'b1;
    edge_cnt_en     = 1'b1;
    stop_chk_en = 1'b0;
    par_chk_en  = 1'b0;
    deser_en    = 1'b0;
    data_valid_comp = 1'b0;
    start_chk_en = 1'b0;

    case (cs)

        // -------------------- IDLE --------------------
        IDLE: begin
            stop_chk_en = 1'b0;
            par_chk_en  = 1'b0;
            deser_en    = 1'b0;
            data_valid_comp = 1'b0;
            if (RX_IN == 1'b1) begin
                ns = IDLE;
                edge_cnt_en    = 1'b0;
                data_sample_en = 1'b0;
                start_chk_en   = 1'b0;
            end else begin
                edge_cnt_en    = 1'b1;
                data_sample_en = 1'b1;
                start_chk_en   = 1'b0;
                ns             = START;
            end
        end

        // -------------------- START --------------------
        START: begin
            stop_chk_en = 1'b0;
            par_chk_en  = 1'b0;
            deser_en    = 1'b0;
            data_valid_comp = 1'b0;

            if (in_sample_window) begin
                if (sample_confirmed) begin
                    start_chk_en = 1'b1;         
                                                
                    if (start_glitch == 1'b0) begin
                        ns          = READ;       // real start bit -> go read data
                        edge_cnt_en = 1'b1;
                    end else begin
                        ns          = IDLE;       // glitch -> abort frame
                        edge_cnt_en = 1'b0;
                    end
                end else begin
                    ns           = START;         // still inside window, sample not confirmed
                    edge_cnt_en  = 1'b1;
                    start_chk_en = 1'b0;
                end
            end else begin
                ns          = START;              // outside sample window
                edge_cnt_en = 1'b1;
                start_chk_en = 1'b0;
            end
        end

        // -------------------- READ --------------------
        READ: begin
            par_chk_en   = 1'b0;
            stop_chk_en  = 1'b0;
            start_chk_en = 1'b0;
            data_valid_comp = 1'b0;

            if (bit_cnt != (DATA_WIDTH + 1)) begin
                ns = READ;                     // still collecting data bits
                deser_en = (sample_confirmed) ? 1'b1 : 1'b0;
                par_chk_en = 1'b0;
                stop_chk_en = 1'b0;
            end else if (parity_en) begin
                ns = PARITY;
                deser_en = 1'b0;
                stop_chk_en = 1'b0;
            end else begin
                ns = STOP;
                deser_en = 1'b0;
                stop_chk_en = 1'b0;
            end
        end

        // -------------------- PARITY --------------------
        PARITY: begin
            deser_en     = 1'b0;
            start_chk_en = 1'b0;
            stop_chk_en  = 1'b0;
            data_valid_comp = 1'b0;
            par_chk_en   = 1'b1;              // CHANGED: high for the whole PARITY state

            if (edge_cnt == prescale -1 ) begin
                ns = STOP;
            end 
            else begin 
                ns = PARITY ;
            end
        end

        // -------------------- STOP --------------------
        STOP: begin
            deser_en     = 1'b0;
            par_chk_en   = 1'b0;
            start_chk_en = 1'b0;
            stop_chk_en  = 1'b1;              // CHANGED: high for the whole STOP state

            if (edge_cnt == prescale - 1) begin
                    ns = IDLE;
                    edge_cnt_en = 1'b0;
                    data_valid_comp = (data_invalid) ? 1'b0 : 1'b1;
            end
            else begin
                    ns = STOP;
                    data_valid_comp = 1'b0;
            end
        end

        default : ns = IDLE;
    endcase
end

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        data_invalid <= 1'd0;
    end
    else if ((cs == STOP || cs == PARITY) && (par_err || stop_err)) begin
        data_invalid <= 1'b1;
    end else data_invalid <= 1'b0;
end

assign smpl_pulse = sample_confirmed;

endmodule
