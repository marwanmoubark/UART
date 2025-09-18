module FIFO #(
    parameter fifo_depth = 8,
    parameter ptr_width  = 3   // clog2(8) = 3
)(
    input  clk, reset_n,
    input  write_en, read_en,
    input  [7:0]data_in,
    output reg data_valid,
    output fifo_full, fifo_empty,
    output reg [7:0]   data_out
);

    reg [7:0] fifo_memory [fifo_depth-1:0];
    reg [ptr_width:0] fifo_count;  
    reg write_en_d;
    reg [ptr_width-1:0] wr_ptr, rd_ptr;

    wire write_en_posedge = (write_en && !write_en_d);

 
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr      <= 0;
            rd_ptr      <= 0;
            fifo_count  <= 0;
            data_valid  <= 0;
            data_out    <= 0;
            write_en_d <= 1'b0;
        end else begin
            data_valid <= 1'b0;
            write_en_d <= write_en;   

            // Write (on rising edge of write_en)
            if (write_en_posedge && !fifo_full) begin
                fifo_memory[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
            end

            // Read
            if (!fifo_empty && read_en) begin
                data_out   <= fifo_memory[rd_ptr];
                rd_ptr     <= rd_ptr + 1;
                data_valid <= 1'b1;   
            end

            case ({write_en_posedge && !fifo_full, read_en && !fifo_empty})
                2'b10: fifo_count <= fifo_count + 1;  
                2'b01: fifo_count <= fifo_count - 1;  
                default: fifo_count <= fifo_count;    
            endcase
        end

       
    end

    assign fifo_full  = (fifo_count == fifo_depth);
    assign fifo_empty = (fifo_count == 0);

endmodule
