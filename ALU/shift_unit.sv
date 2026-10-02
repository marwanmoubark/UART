module shift_unit # ( parameter Data_Width = 16)
(
input wire  [Data_Width - 1 : 0 ] A , B,
input wire Enable,
input wire [1:0] ALU_FUN,
input wire CLK, RST,
output reg shift_flag,
output reg  [Data_Width - 1 : 0] Result
);
always @(posedge CLK , negedge RST) begin
	if (!RST) begin 
		Result <= 0;
		shift_flag <= 1'b0;
		end
	else if(Enable)
		begin
		shift_flag <= 1'b1;
			case(ALU_FUN) 
					2'b00 : Result <= A >> 1;  // A shifted right
					2'b01 : Result <= A << 1;  // A shifted left
					2'b10 : Result <= B >> 1;  // B shifted right
					2'b11 : Result <= B << 1;  // B shifted left
					default : begin 
								Result <= 0;
								shift_flag <= 1'b0;
							end
			endcase
		end
	else 
		begin
			Result <= 0;
			shift_flag <= 1'b0;
		end
end

endmodule
