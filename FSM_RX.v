module FSM_RX #(parameter oversample = 8)
(
    input rx_data, 
    input Bclk,       // oversampling clock (from baud_gen)
    input reset_n,
    output reg rx_valid,
    output [7:0] data_out  
);


    localparam idle  = 3'b000; 
    localparam start = 3'b001; 
    localparam data  = 3'b011; 
    localparam stop  = 3'b010; 


    
    reg [2:0] sample_cnt;
    reg [2:0] data_cnt; 
    reg [7:0] data_out_reg , data_reg;
    reg [2:0] C_state , N_state;
 
    

    
    
    always @(posedge Bclk or negedge reset_n) begin
        if(~reset_n) begin
            data_reg    <= 8'd0;
            sample_cnt  <= 0; 
            data_cnt    <= 0;
            N_state       <= idle;
            rx_valid    <= 0;
            data_out_reg    <= 8'd0;
        end
        else begin
            rx_valid <= 1'b0;
            C_state <= N_state;
            
            case(C_state) 

            //////////////////// idle ////////////////////        
            idle: begin
                data_reg   <= 8'd0;
                sample_cnt <= 0;
                data_cnt   <= 0;
                rx_valid   <= 0 ;
                if(rx_data == 1'b0) begin  // detect start bit (low)
                    N_state <= start;
                end
            end

            //////////////////// start //////////////////// 
            start: begin
                sample_cnt <= sample_cnt + 1;
                // Sample at the middle of start bit
                if(sample_cnt == (oversample)-1) begin
                    if(rx_data == 1'b0) begin  // Confirm it's still low
                        N_state <= data;
                    end
                    else begin
                        N_state <= idle; // false start bit
                    end
                end
            end

            //////////////////// data ////////////////////             
            data: begin
                sample_cnt <= sample_cnt + 1;
                // Sample at the middle of each data bit
                if(sample_cnt == (oversample)-1) begin
                    data_reg[data_cnt] <= rx_data;
                    sample_cnt <= 0;
                    data_cnt <= data_cnt + 1;
                    
                    if(data_cnt == 7) begin
                        N_state <= stop;
                        sample_cnt <= 0;
                    end
                end
            end

            //////////////////// stop ////////////////////   
            stop: begin
                sample_cnt <= sample_cnt + 1;
                // Verify stop bit at the middle
                if(sample_cnt == (oversample)-1) begin
                    if(rx_data == 1'b1) begin   // Valid stop bit
                        data_out_reg <= data_reg;
                        rx_valid <= 1'b1;
                    end
                    N_state <= idle;
                    sample_cnt <= 0;
                    data_cnt <= 0;
                end
            end

            default: N_state <= idle;
            
            endcase
        end
    end
    
    assign data_out = data_out_reg;
endmodule
