module ALU_TOP # (parameter Data_Width = 16)
(
input wire signed [Data_Width - 1 : 0] A , B,
input wire RST , CLK,
input wire [3:0] ALU_FUN,
output wire arith_flag, logic_flag, shift_flag, cmp_flag,
output wire signed [ (2 * Data_Width) - 1 : 0] arith_out,
output wire [ Data_Width - 1 : 0] logic_out, cmp_out, shift_out 
);

//definig internal signals
wire arith_en, shift_en , logic_en , cmp_en;
//Decoder Instantiation
decoder decoder_unit (.fun_in(ALU_FUN[3:2]) , 
					  .fun_out_1(arith_en) , 
					  .fun_out_2(logic_en) , 
					  .fun_out_3(cmp_en)   ,
					  .fun_out_4(shift_en));
					  
//Arithmatic Unit Instantiation
arith_unit #(.Data_Width(Data_Width)) 
		ARITH_UNIT   (.A(A)                   ,
					  .B(B)                   ,
					  .Enable(arith_en)       ,
					  .ALU_FUN(ALU_FUN[1:0])  ,
					  .CLK(CLK)               ,
					  .RST(RST)               ,
					  .arith_flag(arith_flag) ,
					  .Result(arith_out)     ); 
					  

//LOGIC Unit Instantiation
logic_unit #(.Data_Width(Data_Width)) 
		LOGIC_UNIT   (.A(A)                   ,
					  .B(B)                   ,
					  .Enable(logic_en)       ,
					  .ALU_FUN(ALU_FUN[1:0])  ,
					  .CLK(CLK)               ,
					  .RST(RST)               ,
					  .logic_flag(logic_flag) ,
					  .Result(logic_out)     ); 
			
			
//CMP Unit Instantiation
cmp_unit   #(.Data_Width(Data_Width)) 
		CMP_UNIT     (.A(A)                   ,
					  .B(B)                   ,
					  .Enable(  cmp_en)       ,
					  .ALU_FUN(ALU_FUN[1:0])  ,
					  .CLK(CLK)               ,
					  .RST(RST)               ,
					  .cmp_flag(cmp_flag)     ,
					  .Result(  cmp_out)     ); 
					  

//SHIFT Unit Instantiation
shift_unit #(.Data_Width(Data_Width)) 
		SHIFT_UNIT   (.A(A)                   ,
					  .B(B)                   ,
					  .Enable(shift_en)       ,
					  .ALU_FUN(ALU_FUN[1:0])  ,
					  .CLK(CLK)               ,
					  .RST(RST)               ,
					  .shift_flag(shift_flag) ,
					  .Result(shift_out)     ); 
					  
endmodule