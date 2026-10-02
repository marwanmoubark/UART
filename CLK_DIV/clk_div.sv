module clk_div (
    input  wire        i_ref_clk,
    input  wire        i_rst_n,
    input  wire        i_clk_en,
    input  wire [7:0]  i_div_ratio,

    output wire        o_div_clk
);

    // Division enabled only when ratio is not 0 or 1
    wire clk_div_en = i_clk_en && (i_div_ratio != 8'd0) && (i_div_ratio != 8'd1);

    // If ratio is 0 or 1, pass the reference clock through unchanged
    wire pass = i_clk_en && !clk_div_en;

    wire [7:0] high_cnt = i_div_ratio >> 1;         // floor(n/2)
    wire [7:0] low_cnt  = i_div_ratio - high_cnt;   // ceil(n/2)

    reg  [7:0] counter;
    reg        div_clk;   // drives o_div_clk only (clock use)
    reg        phase;     // internal copy of div_clk (data use only)

    // Uses phase instead of div_clk, so the clock net is never used as data
    wire [7:0] count_target = phase ? high_cnt : low_cnt;

    // counter_rst already includes clk_div_en
    wire counter_rst = clk_div_en && (counter == (count_target - 8'd1));

    // Cycle counter
    always @(posedge i_ref_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            counter <= 8'd0;
        else if (!clk_div_en)
            counter <= 8'd0;
        else if (counter_rst)
            counter <= 8'd0;
        else
            counter <= counter + 8'd1;
    end

    // Divided clock and its internal phase copy toggle together
    always @(posedge i_ref_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            div_clk <= 1'b0;
            phase   <= 1'b0;
        end else if (counter_rst) begin
            div_clk <= !div_clk;
            phase   <= !phase;
        end
    end

    // Output mux: bypass when ratio is 0/1, otherwise the divided clock
    assign o_div_clk = pass ? i_ref_clk : div_clk;

endmodule
