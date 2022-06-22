module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output reg 			valid;
output  			encode;
output reg 			finish;
output reg 	[4:0] 	offset;
output reg 	[4:0] 	match_len;
output reg 	[7:0] 	char_nxt;

reg			[1:0]	current_state, next_state;
reg			[14:0]	counter;
reg			[4:0]	search_index;
reg			[4:0]	lookahead_index;
reg			[3:0]	total_buffer[8192:0];
reg			[3:0]	search_buffer[29:0];
wire				equal[24:0];
wire		[15:0]	current_encode_len;
wire		[6:0]	curr_lookahead_index;
wire		[3:0]	match_char[23:0];
parameter [1:0] IN=2'b00, ENCODE=2'b01, ENCODE_OUT=2'b10, SHIFT_ENCODE=2'b11;
integer i;

assign	encode = 1'b1;

assign	match_char[0] = search_buffer[search_index];
assign	match_char[1] = (search_index >= 'd1) ? search_buffer[search_index - 1] : total_buffer[search_index];
assign	match_char[2] = (search_index >= 'd2) ? search_buffer[search_index - 2] : total_buffer[1 - search_index];
assign	match_char[3] = (search_index >= 'd3) ? search_buffer[search_index - 3] : total_buffer[2 - search_index];
assign	match_char[4] = (search_index >= 'd4) ? search_buffer[search_index - 4] : total_buffer[3 - search_index];
assign	match_char[5] = (search_index >= 'd5) ? search_buffer[search_index - 5] : total_buffer[4 - search_index];
assign	match_char[6] = (search_index >= 'd6) ? search_buffer[search_index - 6] : total_buffer[5 - search_index];
assign	match_char[7] = (search_index >= 'd7) ? search_buffer[search_index - 7] : total_buffer[6 - search_index];
assign	match_char[8] = (search_index >= 'd8) ? search_buffer[search_index - 8] : total_buffer[7 - search_index];
assign	match_char[9] = (search_index >= 'd9) ? search_buffer[search_index - 9] : total_buffer[8 - search_index];
assign	match_char[10] = (search_index >= 'd10) ? search_buffer[search_index - 10] : total_buffer[9 - search_index];
assign	match_char[11] = (search_index >= 'd11) ? search_buffer[search_index - 11] : total_buffer[10 - search_index];
assign	match_char[12] = (search_index >= 'd12) ? search_buffer[search_index - 12] : total_buffer[11 - search_index];
assign	match_char[13] = (search_index >= 'd13) ? search_buffer[search_index - 13] : total_buffer[12 - search_index];
assign	match_char[14] = (search_index >= 'd14) ? search_buffer[search_index - 14] : total_buffer[13 - search_index];
assign	match_char[15] = (search_index >= 'd15) ? search_buffer[search_index - 15] : total_buffer[14 - search_index];
assign	match_char[16] = (search_index >= 'd16) ? search_buffer[search_index - 16] : total_buffer[15 - search_index];
assign	match_char[17] = (search_index >= 'd17) ? search_buffer[search_index - 17] : total_buffer[16 - search_index];
assign	match_char[18] = (search_index >= 'd18) ? search_buffer[search_index - 18] : total_buffer[17 - search_index];
assign	match_char[19] = (search_index >= 'd19) ? search_buffer[search_index - 19] : total_buffer[18 - search_index];
assign	match_char[20] = (search_index >= 'd20) ? search_buffer[search_index - 20] : total_buffer[19 - search_index];
assign	match_char[21] = (search_index >= 'd21) ? search_buffer[search_index - 21] : total_buffer[20 - search_index];
assign	match_char[22] = (search_index >= 'd22) ? search_buffer[search_index - 22] : total_buffer[21 - search_index];
assign	match_char[23] = (search_index >= 'd23) ? search_buffer[search_index - 23] : total_buffer[22 - search_index];

assign	equal[0] = (search_index <= 'd29) ? ((match_char[0] == total_buffer[0]) ? 1'b1 : 1'b0) : 1'b0;
assign	equal[1] = (search_index <= 'd29) ? ((match_char[1] == total_buffer[1]) ? equal[0] : 1'b0) : 1'b0;
assign	equal[2] = (search_index <= 'd29) ? ((match_char[2] == total_buffer[2]) ? equal[1] : 1'b0) : 1'b0;
assign	equal[3] = (search_index <= 'd29) ? ((match_char[3] == total_buffer[3]) ? equal[2] : 1'b0) : 1'b0;
assign	equal[4] = (search_index <= 'd29) ? ((match_char[4] == total_buffer[4]) ? equal[3] : 1'b0) : 1'b0;
assign	equal[5] = (search_index <= 'd29) ? ((match_char[5] == total_buffer[5]) ? equal[4] : 1'b0) : 1'b0;
assign	equal[6] = (search_index <= 'd29) ? ((match_char[6] == total_buffer[6]) ? equal[5] : 1'b0) : 1'b0;
assign	equal[7] = (search_index <= 'd29) ? ((match_char[7] == total_buffer[7]) ? equal[6] : 1'b0) : 1'b0;
assign	equal[8] = (search_index <= 'd29) ? ((match_char[8] == total_buffer[8]) ? equal[7] : 1'b0) : 1'b0;
assign	equal[9] = (search_index <= 'd29) ? ((match_char[9] == total_buffer[9]) ? equal[8] : 1'b0) : 1'b0;
assign	equal[10] = (search_index <= 'd29) ? ((match_char[10] == total_buffer[10]) ? equal[9] : 1'b0) : 1'b0;
assign	equal[11] = (search_index <= 'd29) ? ((match_char[11] == total_buffer[11]) ? equal[10] : 1'b0) : 1'b0;
assign	equal[12] = (search_index <= 'd29) ? ((match_char[12] == total_buffer[12]) ? equal[11] : 1'b0) : 1'b0;
assign	equal[13] = (search_index <= 'd29) ? ((match_char[13] == total_buffer[13]) ? equal[12] : 1'b0) : 1'b0;
assign	equal[14] = (search_index <= 'd29) ? ((match_char[14] == total_buffer[14]) ? equal[13] : 1'b0) : 1'b0;
assign	equal[15] = (search_index <= 'd29) ? ((match_char[15] == total_buffer[15]) ? equal[14] : 1'b0) : 1'b0;
assign	equal[16] = (search_index <= 'd29) ? ((match_char[16] == total_buffer[16]) ? equal[15] : 1'b0) : 1'b0;
assign	equal[17] = (search_index <= 'd29) ? ((match_char[17] == total_buffer[17]) ? equal[16] : 1'b0) : 1'b0;
assign	equal[18] = (search_index <= 'd29) ? ((match_char[18] == total_buffer[18]) ? equal[17] : 1'b0) : 1'b0;
assign	equal[19] = (search_index <= 'd29) ? ((match_char[19] == total_buffer[19]) ? equal[18] : 1'b0) : 1'b0;
assign	equal[20] = (search_index <= 'd29) ? ((match_char[20] == total_buffer[20]) ? equal[19] : 1'b0) : 1'b0;
assign	equal[21] = (search_index <= 'd29) ? ((match_char[21] == total_buffer[21]) ? equal[20] : 1'b0) : 1'b0;
assign	equal[22] = (search_index <= 'd29) ? ((match_char[22] == total_buffer[22]) ? equal[21] : 1'b0) : 1'b0;
assign	equal[23] = (search_index <= 'd29) ? ((match_char[23] == total_buffer[23]) ? equal[22] : 1'b0) : 1'b0;
assign	equal[24] = 1'b0;

assign	current_encode_len = counter + match_len + 'd1;
assign	curr_lookahead_index = lookahead_index + 'd1;


always @(posedge clk or posedge reset)
begin
	if(reset) begin
		current_state <= IN;
		counter <= 15'd0;
		search_index <= 5'd0;
		lookahead_index <= 5'd0;
		valid <= 1'b0;
		finish <= 1'b0;
		offset <= 5'd0;
		match_len <= 5'd0;
		char_nxt <= 8'd0;

		search_buffer[0] <= 4'd0;
		search_buffer[1] <= 4'd0;
		search_buffer[2] <= 4'd0;
		search_buffer[3] <= 4'd0;
		search_buffer[4] <= 4'd0;
		search_buffer[5] <= 4'd0;
		search_buffer[6] <= 4'd0;
		search_buffer[7] <= 4'd0;
		search_buffer[8] <= 4'd0;
		search_buffer[9] <= 4'd0;
		search_buffer[10] <= 4'd0;
		search_buffer[11] <= 4'd0;
		search_buffer[12] <= 4'd0;
		search_buffer[13] <= 4'd0;
		search_buffer[14] <= 4'd0;
		search_buffer[15] <= 4'd0;
		search_buffer[16] <= 4'd0;
		search_buffer[17] <= 4'd0;
		search_buffer[18] <= 4'd0;
		search_buffer[19] <= 4'd0;
		search_buffer[20] <= 4'd0;
		search_buffer[21] <= 4'd0;
		search_buffer[22] <= 4'd0;
		search_buffer[23] <= 4'd0;
		search_buffer[24] <= 4'd0;
		search_buffer[25] <= 4'd0;
		search_buffer[26] <= 4'd0;
		search_buffer[27] <= 4'd0;
		search_buffer[28] <= 4'd0;
		search_buffer[29] <= 4'd0;
	end
	else begin
		current_state <= next_state;
		case(current_state)
			IN: begin
				total_buffer[counter] <= chardata[3:0];
				counter <= (counter == 'd8191) ? 'd0 : counter + 'd1;
			end
			ENCODE: begin
				if(equal[match_len] == 'd1 && search_index < counter && current_encode_len <= 'd8192) begin
					char_nxt <= total_buffer[curr_lookahead_index];
					match_len <= match_len + 'd1;
					offset <= search_index;

					lookahead_index <= curr_lookahead_index;
				end
				else begin
					search_index <= (search_index == 'd31) ? 'd0 : search_index - 'd1;
				end
			end
			ENCODE_OUT: begin
				valid <= 1'b1;
				char_nxt <= (current_encode_len == 'd8193) ? 8'h24 : (match_len == 'd0) ? total_buffer[0] : char_nxt;
				counter <= current_encode_len;
			end
			SHIFT_ENCODE: begin
				finish <= (counter == 'd8193) ? 'd1 : 'd0;
				offset <= 'd0;
				valid <= 'd0;
				match_len <= 'd0;
				search_index <= 'd29;
				lookahead_index <= (lookahead_index == 0) ? 'd0 : lookahead_index - 'd1;

				search_buffer[29] <= search_buffer[28];
				search_buffer[28] <= search_buffer[27];
				search_buffer[27] <= search_buffer[26];
				search_buffer[26] <= search_buffer[25];
				search_buffer[25] <= search_buffer[24];
				search_buffer[24] <= search_buffer[23];
				search_buffer[23] <= search_buffer[22];
				search_buffer[22] <= search_buffer[21];
				search_buffer[21] <= search_buffer[20];
				search_buffer[20] <= search_buffer[19];
				search_buffer[19] <= search_buffer[18];
				search_buffer[18] <= search_buffer[17];
				search_buffer[17] <= search_buffer[16];
				search_buffer[16] <= search_buffer[15];
				search_buffer[15] <= search_buffer[14];
				search_buffer[14] <= search_buffer[13];
				search_buffer[13] <= search_buffer[12];
				search_buffer[12] <= search_buffer[11];
				search_buffer[11] <= search_buffer[10];
				search_buffer[10] <= search_buffer[9];
				search_buffer[9] <= search_buffer[8];
				search_buffer[8] <= search_buffer[7];
				search_buffer[7] <= search_buffer[6];
				search_buffer[6] <= search_buffer[5];
				search_buffer[5] <= search_buffer[4];
				search_buffer[4] <= search_buffer[3];
				search_buffer[3] <= search_buffer[2];
				search_buffer[2] <= search_buffer[1];
				search_buffer[1] <= search_buffer[0];
				search_buffer[0] <= total_buffer[0];

				for (i=0; i<8191; i=i+1) begin
					total_buffer[i] <= total_buffer[i+1];
				end
			end
		endcase
	end
end

always @(*) begin
	case(current_state)
		IN: begin
			next_state = (counter == 'd8191) ? ENCODE : IN;
		end
		ENCODE: begin
			next_state = (search_index == 'd31 || match_len == 'd24) ? ENCODE_OUT : ENCODE;
		end
		ENCODE_OUT: begin
			next_state = SHIFT_ENCODE;
		end
		SHIFT_ENCODE: begin
			next_state = (lookahead_index == 'd0) ? ENCODE : SHIFT_ENCODE;
		end
		default: begin
			next_state = IN;
		end
	endcase
end
endmodule
