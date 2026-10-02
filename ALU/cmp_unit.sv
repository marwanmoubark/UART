module cmp_unit # (parameter Data_Width = 16)
(
input wire  [Data_Width - 1 : 0 ] A , B,
input wire Enable,
input wire [1:0] ALU_FUN,
input wire CLK, RST,
output reg cmp_flag,
output reg  [Data_Width - 1 : 0] Result
);
always @(posedge CLK , negedge RST) begin
	if (!RST) 
		begin
			Result<= 0;
			cmp_flag <= 1'b0;
		end
	else if(Enable)
		begin
			cmp_flag <= 1'b1;
				case(ALU_FUN) 
						2'b00 : Result <= {Data_Width{1'b0}};
						2'b01 : Result <= (A == B) ? {{(Data_Width-1){1'b0}}, 1'b1} : {Data_Width{1'b0}};
						2'b10 : Result <= (A > B)  ? {{(Data_Width-2){1'b0}}, 2'b10} : {Data_Width{1'b0}};
						2'b11 : Result <= (A < B)  ? {{(Data_Width-2){1'b0}}, 2'b11} : {Data_Width{1'b0}};
				default: begin
					Result   <= {Data_Width{1'b0}};
					cmp_flag <= 1'b0;
				end
				endcase
			end
	else
		begin 
			Result <= 0;
			cmp_flag <= 1'b0;
		end
end


endmodule