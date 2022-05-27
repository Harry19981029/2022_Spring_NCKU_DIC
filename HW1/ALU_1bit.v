module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output       result;
output       c_out;
output       set;                 
output       overflow;      

wire a_temp, b_temp, and_temp, or_temp, s_temp;
reg result;

//input a
assign a_temp = (Ainvert) ? ~a : a;

//input b
assign b_temp = (Binvert) ? ~b : b;

//and
assign and_temp = a_temp & b_temp;

//or
assign or_temp = a_temp | b_temp;

//full adder
FA block(.s(s_temp), .carry_out(c_out), .x(a_temp), .y(b_temp), .carry_in(c_in));

//result
always @(*) begin
	case(op)
		2'd0: begin
			result = and_temp;
		end
		2'd1: begin
			result = or_temp;
		end
		2'd2: begin
			result = s_temp;
		end
		2'd3: begin
			result = less;
		end
	endcase
end

//set
assign set = s_temp;

//overflow
assign overflow = c_out ^ c_in;

endmodule
