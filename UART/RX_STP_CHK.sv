module RX_STP_CHK #(
    parameter DATA_WIDTH = 8
)(
    input CLK, RST,
    input stop_chk_en,     // now LEVEL, high for entire STOP state
    input stop_smpl_en,    // NEW: 1-cycle pulse at the sample instant
    input sampled_bit,
    output reg stp_err,
    output reg stp_err_comb  // combinational alert for FSM
);

reg err_reg;

always @(posedge CLK or negedge RST) begin
    if (!RST)
        err_reg <= 1'b0;
    else if (!stop_chk_en)
        err_reg <= 1'b0;                        // left STOP state
    else if (stop_smpl_en && (sampled_bit != 1'b1))
        err_reg <= 1'b1;                        
end

assign stp_err_comb =(stop_chk_en && err_reg );

always @(posedge CLK or negedge RST) begin
    if (!RST) stp_err <= 1'b0;
    else      stp_err <= stp_err_comb;
end

endmodule