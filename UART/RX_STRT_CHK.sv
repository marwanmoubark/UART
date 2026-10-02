module RX_STRT_CHK #(
    parameter DATA_WIDTH = 8
)(
    input strt_chk_en, sampled_bit,
    output reg strt_glitch_comb  //combinational alert for FSM
);

always @(*) begin
    if (strt_chk_en)
        strt_glitch_comb = (sampled_bit != 1'b0);
    else 
        strt_glitch_comb = 1'b0;
end
endmodule