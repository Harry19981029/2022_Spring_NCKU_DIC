module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);
input clk;
input reset;
input [7:0] chardata;
output valid;
output encode;
output finish;
output [3:0] offset;
output [2:0] match_len;
output [7:0] char_nxt;
parameter IDLE = 0, READ_LOOKAHEAD=1, OFFSET_8=2, OFFSET_7=3, OFFSET_6=4, OFFSET_5=5, OFFSET_4=6, OFFSET_3=7, OFFSET_2=8, OFFSET_1=9, OFFSET_0=10, READ=11, OUT=12, FINISH=13;
reg	valid;
reg	encode;
reg	finish;
reg	[3:0] offset;
reg	[2:0] match_len;
reg [7:0] char_nxt;
reg [3:0] count_READ;
reg [11:0] count_IDLE;
reg [2:0] match_temp;
reg [2:0] match_old;
reg [3:0] offset_new;
reg [7:0] lookahead0,lookahead1,lookahead2,lookahead3,lookahead4,lookahead5,lookahead6,lookahead7;
reg [7:0] search0,search1,search2,search3,search4,search5,search6,search7,search8;
reg [3:0] state, next_state;
reg [7:0] total_reg [2048:0];
//next_state
always@(*) begin
	case(state)
		IDLE: begin
			if(count_IDLE == 'd2048)
				next_state = READ_LOOKAHEAD;
			else 
				next_state = IDLE;
		end
		READ_LOOKAHEAD: begin
			next_state = OFFSET_8;
		end
		OFFSET_8: begin
			next_state = OFFSET_7;
		end
		OFFSET_7: begin
			next_state = OFFSET_6;
		end
		OFFSET_6: begin
			next_state = OFFSET_5;
		end
		OFFSET_5: begin
			next_state = OFFSET_4;
		end
		OFFSET_4: begin
			next_state = OFFSET_3;
		end
		OFFSET_3: begin
			next_state = OFFSET_2;
		end
		OFFSET_2: begin
			next_state = OFFSET_1;
		end
		OFFSET_1: begin
			next_state = OFFSET_0;
		end
		OFFSET_0: begin
			next_state = OUT;
		end
		READ: begin
			if(count_READ == match_old - 4'b1)
				next_state = OFFSET_8;
			else
				next_state = READ;
		end
		OUT: begin
			if(char_nxt == 8'h24)
				next_state = FINISH;
			else if (match_old == 4'b0)
				next_state = OFFSET_8;
			else
				next_state = READ;
		end
		FINISH: begin
			next_state = FINISH;
		end
		default: begin
			next_state = state;
		end
	endcase
end
//state_reg
always@(posedge clk or posedge reset)begin
	if(reset)
		state <= IDLE;
	else
		state <= next_state;
end
always@(posedge clk or posedge reset)begin
	if(reset)
		{count_READ, count_IDLE} <= 16'b0;
	else begin
		case(state)
			IDLE: begin
				if(count_IDLE == 12'd2048)
					count_IDLE <= 12'd0;
				else
					count_IDLE <= count_IDLE + 12'b1;
			end
			READ_LOOKAHEAD: begin
				count_IDLE <= 12'd8;
			end
			OFFSET_8: begin
				count_READ <= 0;
			end
			OFFSET_7: begin
				count_READ <= 0;
			end
			OFFSET_6: begin
				count_READ <= 0;
			end
			OFFSET_5: begin
				count_READ <= 0;
			end
			OFFSET_4: begin
				count_READ <= 0;
			end
			OFFSET_3: begin
				count_READ <= 0;
			end
			OFFSET_2: begin
				count_READ <= 0;
			end
			OFFSET_1: begin
				count_READ <= 0;
			end
			OFFSET_0: begin
				count_READ <= 0;
			end
			READ: begin
				count_IDLE <= count_IDLE + 12'b1;
				if(count_READ == match_old - 4'b1)
					count_READ <= 4'b0;
				else
					count_READ <= count_READ + 4'b1;
			end
			OUT: begin
				count_IDLE <= count_IDLE + 12'b1;
			end
			FINISH: begin
				count_READ <= 0;
			end
			default: begin
				count_READ <= 0;
			end
		endcase
	end
end
always@(posedge clk or posedge reset) begin
	if(reset) begin
		lookahead0 <= 'h0;
		lookahead1 <= 'h0;
		lookahead2 <= 'h0;
		lookahead3 <= 'h0;
		lookahead4 <= 'h0;
		lookahead5 <= 'h0;
		lookahead6 <= 'h0;
		lookahead7 <= 'h0;
		search0 <= 'h36;
		search1 <= 'h36; 
		search2 <= 'h36;
		search3 <= 'h36;
		search4 <= 'h36;
		search5 <= 'h36;
		search6 <= 'h36;
		search7 <= 'h36;
		search8 <= 'h36;
		{match_old, offset_new} <= 'd0;
	end
	else begin
		if(state == IDLE) begin
			total_reg[count_IDLE] <= chardata;
		end
		else if(state == READ_LOOKAHEAD) begin
			lookahead0 <= total_reg[7];
			lookahead1 <= total_reg[6];
			lookahead2 <= total_reg[5];
			lookahead3 <= total_reg[4];
			lookahead4 <= total_reg[3];
			lookahead5 <= total_reg[2];
			lookahead6 <= total_reg[1];
			lookahead7 <= total_reg[0];
		end
		else if(state == OFFSET_8 || state == OFFSET_7 || state == OFFSET_6 || state == OFFSET_5 || state == OFFSET_4 || state == OFFSET_3 || state == OFFSET_2 || state == OFFSET_1 || state == OFFSET_0) begin
			if(match_old < match_temp) begin
				match_old  <= match_temp;
				offset_new <= 10 - state;
			end
			else begin
				match_old  <= match_old;
				offset_new <= offset_new;
			end
		end
		else if(state == READ || state == OUT) begin
			lookahead0 <= total_reg[count_IDLE];
			lookahead1 <= lookahead0;
			lookahead2 <= lookahead1;
			lookahead3 <= lookahead2;
			lookahead4 <= lookahead3;
			lookahead5 <= lookahead4;
			lookahead6 <= lookahead5;
			lookahead7 <= lookahead6;
			search0 <= lookahead7;
			search1 <= search0;
			search2 <= search1;
			search3 <= search2;
			search4 <= search3;
			search5 <= search4;
			search6 <= search5;
			search7 <= search6;
			search8 <= search7;
			if(state == READ) begin
				if(count_READ == match_old - 4'b1)
					{match_old, offset_new} <= 'd0;
			end	
		end
	end		
end
//output
always@(*) begin
	case(state)
		IDLE: begin
			{encode,finish,valid} = 3'b000;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
		end
		READ_LOOKAHEAD: begin
			{encode, finish, valid}=3'b000;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
		end
		OFFSET_8: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search8 && lookahead6 == search7 && lookahead5 == search6 && lookahead4 == search5 && lookahead3 == search4 && lookahead2 == search3 && lookahead1 == search2)
				match_temp = 3'd7;
			else if(lookahead7 == search8 && lookahead6 == search7 && lookahead5 == search6 && lookahead4 == search5 && lookahead3 == search4 && lookahead2 == search3)
				match_temp = 3'd6;
			else if(lookahead7 == search8 && lookahead6 == search7 && lookahead5 == search6 && lookahead4 == search5 && lookahead3 == search4)
				match_temp = 3'd5;
			else if(lookahead7 == search8 && lookahead6 == search7 && lookahead5 == search6 && lookahead4 == search5)
				match_temp = 3'd4;
			else if(lookahead7 == search8 && lookahead6 == search7 && lookahead5 == search6)
				match_temp = 3'd3;
			else if(lookahead7 == search8 && lookahead6 == search7)
				match_temp = 3'd2;
			else if	(lookahead7 == search8)
				match_temp = 3'd1;
			else
				match_temp = 3'd0;
		end
		OFFSET_7: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search7 & lookahead6 == search6 & lookahead5 == search5 & lookahead4 == search4 & lookahead3 == search3 & lookahead2 == search2 & lookahead1 == search1)
				match_temp = 3'd7; 
			else if(lookahead7 == search7 & lookahead6 == search6 & lookahead5 == search5 & lookahead4 == search4 & lookahead3 == search3 & lookahead2 == search2)
				match_temp = 3'd6; 
			else if(lookahead7 == search7 & lookahead6 == search6 & lookahead5 == search5 & lookahead4 == search4 & lookahead3 == search3)
				match_temp = 3'd5; 
			else if(lookahead7 == search7 & lookahead6 == search6 & lookahead5 == search5 & lookahead4 == search4)
				match_temp = 3'd4; 
			else if(lookahead7 == search7 & lookahead6 == search6 & lookahead5 == search5)
				match_temp = 3'd3; 
			else if(lookahead7 == search7 & lookahead6 == search6)
				match_temp = 3'd2;
			else if(lookahead7 == search7)
				match_temp = 3'd1;
			else
				match_temp = 3'd0;	
		end
		OFFSET_6: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search6 & lookahead6 == search5 & lookahead5 == search4 & lookahead4 == search3 & lookahead3 == search2 & lookahead2 == search1 & lookahead1 == search0)
				match_temp = 3'd7;                                            
			else if(lookahead7 == search6 & lookahead6 == search5 & lookahead5 == search4 & lookahead4 == search3 & lookahead3 == search2 & lookahead2 == search1)
				match_temp = 3'd6;                                 
			else if(lookahead7 == search6 & lookahead6 == search5 & lookahead5 == search4 & lookahead4 == search3 & lookahead3 == search2)
				match_temp = 3'd5;                      
			else if(lookahead7 == search6 & lookahead6 == search5 & lookahead5 == search4 & lookahead4 == search3)
				match_temp = 3'd4;           
			else if(lookahead7 == search6 & lookahead6 == search5 & lookahead5 == search4)
				match_temp = 3'd3;
			else if(lookahead7 == search6 & lookahead6 == search5)
				match_temp = 3'd2;
			else if(lookahead7 == search6)
				match_temp = 3'd1;
			else    
				match_temp = 3'd0;
		end
		OFFSET_5: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search5 & lookahead6 == search4 & lookahead5 == search3 & lookahead4 == search2 & lookahead3 == search1 & lookahead2 == search0 & lookahead1 == lookahead7)
				match_temp = 3'd7;                                            
			else if(lookahead7 == search5 & lookahead6 == search4 & lookahead5 == search3 & lookahead4 == search2 & lookahead3 == search1 & lookahead2 == search0)
				match_temp = 3'd6;                                 
			else if(lookahead7 == search5 & lookahead6 == search4 & lookahead5 == search3 & lookahead4 == search2 & lookahead3 == search1)
				match_temp = 3'd5;                      
			else if(lookahead7 == search5 & lookahead6 == search4 & lookahead5 == search3 & lookahead4 == search2)
				match_temp = 3'd4;           
			else if(lookahead7 == search5 & lookahead6 == search4 & lookahead5 == search3)
				match_temp = 3'd3;
			else if(lookahead7 == search5 & lookahead6 == search4)
				match_temp = 3'd2;
			else if(lookahead7 == search5)
				match_temp = 3'd1;
			else    
				match_temp = 3'd0;
		end
		OFFSET_4: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search4 & lookahead6 == search3 & lookahead5 == search2 & lookahead4 == search1 & lookahead3 == search0 & lookahead2 == lookahead7 & lookahead1 == lookahead6)
				match_temp = 3'd7;                                                       
			else if(lookahead7 == search4 & lookahead6 == search3 & lookahead5 == search2 & lookahead4 == search1 & lookahead3 == search0 & lookahead2 == lookahead7)
				match_temp = 3'd6;                                 
			else if(lookahead7 == search4 & lookahead6 == search3 & lookahead5 == search2 & lookahead4 == search1 & lookahead3 == search0)
				match_temp = 3'd5;                      
			else if(lookahead7 == search4 & lookahead6 == search3 & lookahead5 == search2 & lookahead4 == search1)
				match_temp = 3'd4;           
			else if(lookahead7 == search4 & lookahead6 == search3 & lookahead5 == search2)
				match_temp = 3'd3;
			else if(lookahead7 == search4 & lookahead6 == search3)
				match_temp = 3'd2;
			else if(lookahead7 == search4)
				match_temp = 3'd1;
			else    
				match_temp = 3'd0;
		end
		OFFSET_3: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search3 & lookahead6 == search2 & lookahead5 == search1 & lookahead4 == search0 & lookahead3 == lookahead7 & lookahead2 == lookahead6 & lookahead1 == lookahead5)
				match_temp = 3'd7;                                                 
			else if(lookahead7 == search3 & lookahead6 == search2 & lookahead5 == search1 & lookahead4 == search0 & lookahead3 == lookahead7 & lookahead2 == lookahead6)
				match_temp = 3'd6;                                 
			else if(lookahead7 == search3 & lookahead6 == search2 & lookahead5 == search1 & lookahead4 == search0 & lookahead3 == lookahead7)
				match_temp = 3'd5;                      
			else if(lookahead7 == search3 & lookahead6 == search2 & lookahead5 == search1 & lookahead4 == search0)
				match_temp = 3'd4;           
			else if(lookahead7 == search3 & lookahead6 == search2 & lookahead5 == search1)
				match_temp = 3'd3;
			else if(lookahead7 == search3 & lookahead6 == search2)
				match_temp = 3'd2;
			else if(lookahead7 == search3)
				match_temp = 3'd1;
			else    
				match_temp = 3'd0;
		end
		OFFSET_2: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search2 & lookahead6 == search1 & lookahead5 == search0 & lookahead4 == lookahead7 & lookahead3 == lookahead6 & lookahead2 == lookahead5 & lookahead1 == lookahead4)
				match_temp = 3'd7;                                                  
			else if(lookahead7 == search2 & lookahead6 == search1 & lookahead5 == search0 & lookahead4 == lookahead7 & lookahead3 == lookahead6 & lookahead2 == lookahead5)
				match_temp = 3'd6;                                 
			else if(lookahead7 == search2 & lookahead6 == search1 & lookahead5 == search0 & lookahead4 == lookahead7 & lookahead3 == lookahead6)
				match_temp = 3'd5;                    
			else if(lookahead7 == search2 & lookahead6 == search1 & lookahead5 == search0 & lookahead4 == lookahead7)
				match_temp = 3'd4;           
			else if(lookahead7 == search2 & lookahead6 == search1 & lookahead5 == search0)
				match_temp = 3'd3;
			else if(lookahead7 == search2 & lookahead6 == search1)
				match_temp = 3'd2;
			else if(lookahead7 == search2)
				match_temp = 3'd1;
			else    
				match_temp = 3'd0;
		end
		OFFSET_1: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search1 & lookahead6 == search0 & lookahead5 == lookahead7 & lookahead4 == lookahead6 & lookahead3 == lookahead5 & lookahead2 == lookahead4 & lookahead1 == lookahead3)
				match_temp = 3'd7;                     	
			else if(lookahead7 == search1 & lookahead6 == search0 & lookahead5 == lookahead7 & lookahead4 == lookahead6 & lookahead3 == lookahead5 & lookahead2 == lookahead4)
				match_temp = 3'd6;                                 
			else if(lookahead7 == search1 & lookahead6 == search0 & lookahead5 == lookahead7 & lookahead4 == lookahead6 & lookahead3 == lookahead5)
				match_temp = 3'd5;                      
			else if(lookahead7 == search1 & lookahead6 == search0 & lookahead5 == lookahead7 & lookahead4 == lookahead6)
				match_temp = 3'd4;           
			else if(lookahead7 == search1 & lookahead6 == search0 & lookahead5 == lookahead7)
				match_temp = 3'd3;
			else if(lookahead7 == search1 & lookahead6 == search0)
				match_temp = 3'd2;
			else if(lookahead7 == search1)
				match_temp = 3'd1;
			else    
				match_temp = 3'd0;
		end
		OFFSET_0: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
			if(lookahead7 == search0 & lookahead6 == lookahead7 & lookahead5 == lookahead6 & lookahead4 == lookahead5 & lookahead3 == lookahead4 & lookahead2 == lookahead3 & lookahead1 == lookahead2)
				match_temp = 3'd7;                                                  
			else if(lookahead7 == search0 & lookahead6 == lookahead7 & lookahead5 == lookahead6 & lookahead4 == lookahead5 & lookahead3 == lookahead4 & lookahead2 == lookahead3)
				match_temp = 3'd6;                                 
			else if(lookahead7 == search0 & lookahead6 == lookahead7 & lookahead5 == lookahead6 & lookahead4 == lookahead5 & lookahead3 == lookahead4)
				match_temp = 3'd5;                      
			else if(lookahead7 == search0 & lookahead6 == lookahead7 & lookahead5 == lookahead6 & lookahead4 == lookahead5)
				match_temp = 3'd4;           
			else if(lookahead7 == search0 & lookahead6 == lookahead7 & lookahead5 == lookahead6)
				match_temp = 3'd3;
			else if(lookahead7 == search0 & lookahead6 == lookahead7)
				match_temp = 3'd2;
			else if(lookahead7 == search0)
				match_temp = 3'd1;
			else    
				match_temp = 3'd0;
		end
		READ: begin
			{encode,finish,valid} = 3'b100;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
		end
		OUT: begin
			{encode,finish,valid} = 3'b101;
			offset = offset_new;
			match_len = match_old;
			case(match_old)
				'd0: char_nxt = lookahead7;
				'd1: char_nxt = lookahead6;
				'd2: char_nxt = lookahead5;
				'd3: char_nxt = lookahead4;
				'd4: char_nxt = lookahead3;
				'd5: char_nxt = lookahead2;
				'd6: char_nxt = lookahead1;
				'd7: char_nxt = lookahead0;
			endcase
		end
		FINISH: begin
			{encode,finish,valid} = 3'b110;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
		end
		default: begin
			{encode,finish,valid} = 3'b000;
			offset = 'h0;
			match_len = 'h0;
			char_nxt = 'h0;
		end
	endcase
end
endmodule

