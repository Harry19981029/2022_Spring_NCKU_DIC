module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);
input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode;
output  			finish;
output 	 	[7:0] 	char_nxt;
reg encode;
reg finish;
reg [7:0] char_nxt;
reg [2:0] count;
reg [7:0] SEARCH [8:0];
always @(posedge clk, posedge reset) begin
	if(reset) begin
		SEARCH[0] <= 8'h0;
		SEARCH[1] <= 8'h0;
		SEARCH[2] <= 8'h0;
		SEARCH[3] <= 8'h0;
		SEARCH[4] <= 8'h0;
		SEARCH[5] <= 8'h0;
		SEARCH[6] <= 8'h0;
		count <= 3'b0;
	end
	else begin
		encode <= 1'b0; 
		SEARCH[1] <= SEARCH[0];
		SEARCH[2] <= SEARCH[1];
		SEARCH[3] <= SEARCH[2];
		SEARCH[4] <= SEARCH[3];
		SEARCH[5] <= SEARCH[4];
		SEARCH[6] <= SEARCH[5];
		if(char_nxt == 8'h24)
			finish = 1'b1;
		else
			finish = 1'b0;
		if(code_len == 3'b0 || count == code_len) begin
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
endmodule