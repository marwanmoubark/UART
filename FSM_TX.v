module FSM_tx (
    input        Bclk, 
    input        reset_n, 
    input        tx_start, 
    input  [7:0] data_in,
    output reg   tx_busy ,
    output reg   tx_data 

);


    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    // Registers
    reg [1:0] C_state, N_state;
    reg [7:0] shift_reg;
    reg [2:0] bit_count;


    // Sequential block
    always @(posedge Bclk or negedge reset_n) begin
        if (!reset_n) begin
            C_state   <= IDLE;
            tx_data   <= 1'b1;
            tx_busy   <= 1'b0;
            shift_reg <= 8'h00;
            bit_count <= 3'd0;
        end
        else begin
            C_state <= N_state;
            
            // Sequential updates
            case (C_state)
                IDLE: begin
                    bit_count <= 0;
                    tx_data <= 1'b1;

                    if(N_state == START) begin 
                    tx_busy <= 1'b1;
                    end

                    else begin
                        tx_busy <= 1'b0;
                    end

                    if (tx_start) begin  
                        N_state <= START;
                        shift_reg <= data_in;
                        tx_busy <= 1'b1;
                    end
                end
                START: begin
                    shift_reg <= data_in ;
                    tx_data <= 1'b0;   // Start bit
                    tx_busy <= 1'b1;
                    N_state <= DATA;
                end

                DATA: begin
                    tx_data   <= shift_reg[0];  // LSB first
                    shift_reg <= {1'b1, shift_reg[7:1]};
                    tx_busy <= 1'b1;

                    if (bit_count == 3'd7) begin
                        N_state <= STOP;
                    end else begin
                        bit_count <= bit_count + 1;
                    end
                end

                STOP: begin
                    bit_count <= 3'd0;
                    tx_data <= 1'b1;   // Stop bit
                   tx_busy <= 1'b1;
                    N_state   <= IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        //tx_data <= 1'b1 ;
        if (tx_start == 1) begin
            N_state <= START;
            tx_busy <= 1'b1;
        end
    end

    endmodule