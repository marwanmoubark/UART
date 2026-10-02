module RX_PAR_CHK #(
    parameter DATA_WIDTH = 8
)(
    input CLK, RST,
    input wire sampled_bit,
    input wire [DATA_WIDTH-1:0] p_data,
    input wire par_type,
    input wire par_chk_en,     // now LEVEL, high for entire PARITY state
    input wire par_smpl_en,    // NEW: 1-cycle pulse at the sample instant
    output reg par_err,        // Top module registered output
    output reg par_err_comb    // combinational alert for fsm
);

wire exp_parity_bit;
reg  err_reg;

assign exp_parity_bit = (par_type) ? ~^p_data : ^p_data;

always @(posedge CLK or negedge RST) begin
    if (!RST)
        err_reg <= 1'b0;
    else if (!par_chk_en)
        err_reg <= 1'b0;                              // left PARITY state
    else if (par_smpl_en && (exp_parity_bit != sampled_bit))
        err_reg <= 1'b1;                              
end

// Combinational alert: high from the sample instant through
// the rest of the PARITY state
assign par_err_comb = par_chk_en && err_reg ;

always @(posedge CLK or negedge RST) begin
    if (!RST) par_err <= 1'b0;
    else      par_err <= par_err_comb;
end

endmodule