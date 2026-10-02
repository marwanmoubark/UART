module decoder (
input wire [1:0] fun_in,
output reg fun_out_1, fun_out_2, fun_out_3, fun_out_4
);
always @(*)
	begin
	fun_out_1 = 0;
	fun_out_2 = 0;
	fun_out_3 = 0;
	fun_out_4 = 0;
		case (fun_in)
			2'b00:fun_out_1 = 1;
			2'b01:fun_out_2 = 1;
			2'b10:fun_out_3 = 1;
			2'b11:fun_out_4 = 1;
			default : begin 
				fun_out_1 = 0;
				fun_out_2 = 0;
				fun_out_3 = 0;
				fun_out_4 = 0;
			end
		endcase
	end
endmodule