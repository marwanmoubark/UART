module pulse_gen (
    input  wire CLK,
    input  wire RST,  // Active-low reset
    input  wire in_sig,
    output wire pulse
);

    reg in_sig_d; 

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            in_sig_d <= 1'b0;
        end else begin
            // store previous value
            in_sig_d <= in_sig;
        end
    end
    assign pulse = (in_sig & ~in_sig_d);

endmodule
