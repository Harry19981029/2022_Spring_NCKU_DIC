module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;
wire [6:0] c_out;
wire less_temp;
wire set_temp;

assign less_temp = overflow ^ set_temp;
assign zero = ~(result[0] | result[1] | result[2] | result[3] | result[4] | result[5] | result[6] | result[7]);

ALU_1bit ALU0 (.result(result[0]), .c_out(c_out[0]), .set(), .overflow(),
               .a(ALU_src1[0]), .b(ALU_src2[0]), .less(less_temp), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert), .op(op[1:0]));
			   
ALU_1bit ALU1 (.result(result[1]), .c_out(c_out[1]), .set(), .overflow(), 
               .a(ALU_src1[1]), .b(ALU_src2[1]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out[0]), .op(op[1:0]));
			   
ALU_1bit ALU2 (.result(result[2]), .c_out(c_out[2]), .set(), .overflow(), 
               .a(ALU_src1[2]), .b(ALU_src2[2]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out[1]), .op(op[1:0]));
			   
ALU_1bit ALU3 (.result(result[3]), .c_out(c_out[3]), .set(), .overflow(), 
               .a(ALU_src1[3]), .b(ALU_src2[3]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out[2]), .op(op[1:0]));
			   
ALU_1bit ALU4 (.result(result[4]), .c_out(c_out[4]), .set(), .overflow(), 
               .a(ALU_src1[4]), .b(ALU_src2[4]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out[3]), .op(op[1:0]));
			   
ALU_1bit ALU5 (.result(result[5]), .c_out(c_out[5]), .set(), .overflow(), 
               .a(ALU_src1[5]), .b(ALU_src2[5]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out[4]), .op(op[1:0]));
			   
ALU_1bit ALU6 (.result(result[6]), .c_out(c_out[6]), .set(), .overflow(), 
               .a(ALU_src1[6]), .b(ALU_src2[6]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out[5]), .op(op[1:0]));
			   
ALU_1bit ALU7 (.result(result[7]), .c_out(), .set(set_temp), .overflow(overflow), 
               .a(ALU_src1[7]), .b(ALU_src2[7]), .less(1'b0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_out[6]), .op(op[1:0]));
			   
endmodule
