module arith_unit # ( parameter Data_Width = 16)
(
input wire signed [Data_Width - 1 : 0 ] A , B,
input wire Enable,
input wire [1:0] ALU_FUN,
input wire CLK, RST,
output reg arith_flag,
output reg signed [(2 * Data_Width) - 1 : 0] Result
);
always @(posedge CLK , negedge RST) begin
	if (!RST)
		begin 
			Result <= 0;
			arith_flag <= 1'b0;
		end

	else if(Enable) 
		begin
			arith_flag <= 1'b1;
			case(ALU_FUN) 
					2'b00 : Result <= A + B;
					2'b01 : Result <= A - B;
					2'b10 : Result <= A * B;
					2'b11 : Result <= A / B;
					default : begin 
					Result <= 0;
					arith_flag <= 1'b0;
					end
			endcase
		end
		
	else
		begin
			Result     <= 0    ;
			arith_flag <= 1'b0 ;
		end
end


endmodule