`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2025 01:59:35 AM
// Design Name: 
// Module Name: baud_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baud_gen #(parameter F_sys = 50000000)
(
    input [3:0] baud_rate,
    input clk , reset_n ,
    output baud_tx, baud_rx 
);

    reg[12:0]  K ;
    reg tick_tx , tick_rx;
    reg [12:0] Counter_tx , Counter_rx;
    
   


   

    always @(*) begin 
    case(baud_rate) 
     4'b0100 : K = F_sys/(2*9600);
     4'b0101 : K = F_sys/(2*19200);
     4'b0110 : K = F_sys/(2*38400);
     4'b0111 : K = F_sys/(2*57600);
     4'b1000 : K = F_sys/(2*115200);
    default : K = F_sys/(2*9600);
    endcase 
    end
    
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            tick_tx<= 1'b0 ;
            Counter_tx <= 16'b0;
        end
        
        else begin 
            if (Counter_tx >= K) begin
                Counter_tx <= 0;
                tick_tx <= ~tick_tx;
                end
                
            else begin
                Counter_tx <= Counter_tx + 1;
                end
            end 

end

 always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            tick_rx<= 1'b0 ;
            Counter_rx <= 16'b0;
        end
        
        else begin 
            if (Counter_rx >= (K/8)) begin
                Counter_rx <= 0;
                tick_rx <= ~tick_rx;
                end
                
            else begin
                Counter_rx <= Counter_rx + 1;
                end
            end 

end

      assign baud_tx = tick_tx;
      assign baud_rx = tick_rx;
endmodule
