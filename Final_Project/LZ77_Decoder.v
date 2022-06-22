module LZ77_Decoder(clk,reset,ready,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input				ready;
input 		[4:0] 	code_pos;
input 		[4:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode;
output  			finish;
output 	    [7:0] 	char_nxt;

reg encode;
reg finish;
reg [7:0] char_nxt;
reg [4:0] count;
reg [7:0] SEARCH [29:0];
always @(posedge clk, posedge reset) begin
	if(reset) begin
		SEARCH[0] <= 8'h0;
		SEARCH[1] <= 8'h0;
		SEARCH[2] <= 8'h0;
		SEARCH[3] <= 8'h0;
		SEARCH[4] <= 8'h0;
		SEARCH[5] <= 8'h0;
		SEARCH[6] <= 8'h0;
		SEARCH[7] <= 8'h0;
		SEARCH[8] <= 8'h0;
		SEARCH[9] <= 8'h0;
		SEARCH[10] <= 8'h0;
		SEARCH[11] <= 8'h0;
		SEARCH[12] <= 8'h0;
		SEARCH[13] <= 8'h0;
		SEARCH[14] <= 8'h0;
		SEARCH[15] <= 8'h0;
		SEARCH[16] <= 8'h0;
		SEARCH[17] <= 8'h0;
		SEARCH[18] <= 8'h0;
		SEARCH[19] <= 8'h0;
		SEARCH[20] <= 8'h0;
		SEARCH[21] <= 8'h0;
		SEARCH[22] <= 8'h0;
		SEARCH[23] <= 8'h0;
		SEARCH[24] <= 8'h0;
		SEARCH[25] <= 8'h0;
		SEARCH[26] <= 8'h0;
		SEARCH[27] <= 8'h0;
		SEARCH[28] <= 8'h0;
		SEARCH[29] <= 8'h0;
		count <= 5'b0;
	end
	else begin
		encode <= 1'b0; 
		SEARCH[1] <= SEARCH[0];
		SEARCH[2] <= SEARCH[1];
		SEARCH[3] <= SEARCH[2];
		SEARCH[4] <= SEARCH[3];
		SEARCH[5] <= SEARCH[4];
		SEARCH[6] <= SEARCH[5];
		SEARCH[7] <= SEARCH[6];
		SEARCH[8] <= SEARCH[7];
		SEARCH[9] <= SEARCH[8];
		SEARCH[10] <= SEARCH[9];
		SEARCH[11] <= SEARCH[10];
		SEARCH[12] <= SEARCH[11];
		SEARCH[13] <= SEARCH[12];
		SEARCH[14] <= SEARCH[13];
		SEARCH[15] <= SEARCH[14];
		SEARCH[16] <= SEARCH[15];
		SEARCH[17] <= SEARCH[16];
		SEARCH[18] <= SEARCH[17];
		SEARCH[19] <= SEARCH[18];
		SEARCH[20] <= SEARCH[19];
		SEARCH[21] <= SEARCH[20];
		SEARCH[22] <= SEARCH[21];
		SEARCH[23] <= SEARCH[22];
		SEARCH[24] <= SEARCH[23];
		SEARCH[25] <= SEARCH[24];
		SEARCH[26] <= SEARCH[25];
		SEARCH[27] <= SEARCH[26];
		SEARCH[28] <= SEARCH[27];
		SEARCH[29] <= SEARCH[28];
		if(char_nxt == 8'h24)
			finish <= 1'b1;
		else
			finish <= 1'b0;
		if(ready == 1'd1) begin
			if(code_len == 5'b0 || count == code_len) begin
				count <= 3'b0;
				char_nxt <= chardata;
				SEARCH[0] <= chardata;
			end
			else begin
				count <= count + 1'b1;
				char_nxt <= SEARCH[code_pos];
				SEARCH[0] <= SEARCH[code_pos];
			end		
		end
	end
end
endmodule
