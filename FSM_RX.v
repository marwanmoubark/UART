module FSM_RX #(parameter oversample = 8)
(
    input rx_data, 
    input Bclk,       // oversampling clock (from baud_gen)
    input reset_n,
    output reg rx_valid,
    output [7:0] data_out  
);



    reg [2:0] sample_cnt;
    reg [2:0] data_cnt; 
    reg [7:0] data_reg , data_out_reg;
    reg [1:0] state;
 
    
    localparam idle  = 0; 
    localparam start = 1; 
    localparam data  = 2; 
    localparam stop  = 3; 
    
    
    always @(posedge Bclk or negedge reset_n) begin
        if(~reset_n) begin
            data_reg    <= 8'd0;
            sample_cnt  <= 0; 
            data_cnt    <= 0;
            state       <= idle;
            rx_valid    <= 0;
            data_out_reg    <= 8'd0;
        end
        else begin
            rx_valid <= 1'b0;
            
            case(state) 

            //////////////////// idle ////////////////////        
            idle: begin
                data_reg   <= 8'd0;
                sample_cnt <= 0;
                data_cnt   <= 0;
                rx_valid   <= 0 ;
                if(rx_data == 1'b0) begin  // detect start bit (low)
                    state <= start;
                end
            end

            //////////////////// start //////////////////// 
            start: begin
                sample_cnt <= sample_cnt + 1;
                // Sample at the middle of start bit
                if(sample_cnt == (oversample)-1) begin
                    if(rx_data == 1'b0) begin  // Confirm it's still low
                        state <= data;
                    end
                    else begin
                        state <= idle; // false start bit
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
                        state <= stop;
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
                    state <= idle;
                    sample_cnt <= 0;
                    data_cnt <= 0;
                end
            end

            default: state <= idle;
            
            endcase
        end
    end

    assign rx_state = state ;
    assign bit_sample_cnt = sample_cnt;
    assign data_out = data_out_reg;
    assign current_data = data_reg;
endmodule