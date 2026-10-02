module rst_sync # 
(
    parameter N_stage = 3
)
(
    input  wire RST_N,    // Active-low asynchronous reset
    input  wire CLK, 
    output wire sync_rst  // Synchronized active-low reset output
);

reg [N_stage - 1 : 0] ff_stage;

always @(posedge CLK or negedge RST_N) begin
    if (!RST_N) begin
        ff_stage <= {N_stage{1'b0}};
    end
    else begin
        ff_stage[0] <= 1'b1;
        for (integer i = 1; i < N_stage; i = i + 1) begin
            ff_stage[i] <= ff_stage[i-1];
        end 
    end
end

// Assign the last stage of the synchronizer to output
assign sync_rst = ff_stage[N_stage - 1];

endmodule