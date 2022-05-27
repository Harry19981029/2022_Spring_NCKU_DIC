`timescale 1ns/10ps

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output				req;
	output				wen;
	output		[9:0]	addr;
	output		[7:0]	data_wr;
	output				done;

parameter IDLE = 0, LOAD = 1, OUT_PINK = 2, OUT_BLUE = 3, FINISH = 4;
reg req, wen, done;
reg [9:0] addr;
reg [7:0] data_wr;
reg [2:0] state, next_state;
reg [4:0] count_row;
reg [4:0] count_column;
reg [7:0] temp_pink1 [31:0];
reg [7:0] temp_pink2 [31:0];
reg [7:0] D1, D2, D3;
//next_state
always @(*) begin
	case(state)
		IDLE: begin
			next_state = LOAD;
		end
		LOAD: begin
			next_state = OUT_PINK;
		end
		OUT_PINK: begin
			if(count_row < 'd2) begin
				if(count_column == 'd31)
					next_state <= LOAD;
				else
					next_state <= OUT_PINK;
			end
			else begin
				if(count_column == 'd31)
					next_state <= OUT_BLUE;
				else
					next_state <= OUT_PINK;
			end
		end
		OUT_BLUE: begin
			if(count_row == 'd16 && count_column == 'd31)
				next_state <= FINISH;
			else begin
				if(count_column == 'd31)
					next_state <= LOAD;
				else
					next_state <= OUT_BLUE;
			end
		end
		default: begin
			next_state <= state;
		end
	endcase
end
//state_reg
always @(posedge clk or posedge rst) begin
	if(rst) begin
		state <= IDLE;
	end
	else begin
		state <= next_state;
	end
end
always @(posedge clk or posedge rst) begin
	if(rst) begin
		count_row <= 'd0;
	end
	else begin
		if(state == LOAD)
			count_row <= count_row + 1;
		else
			count_row <= count_row;
	end
end
always @(posedge clk or posedge rst) begin
	if(rst) begin
		count_column <= 'd0;
	end
	else begin
		if(state == OUT_PINK || state == OUT_BLUE) begin
			if(count_column < 'd31)
				count_column <= count_column + 1;
			else
				count_column <= 'd0;
		end
		else
			count_column <= 'd0;
	end 
end
always @(posedge clk or posedge rst) begin
	if(rst) begin
		temp_pink1[0] <= 'd0;
		temp_pink1[1] <= 'd0;
		temp_pink1[2] <= 'd0;
		temp_pink1[3] <= 'd0;
		temp_pink1[4] <= 'd0;
		temp_pink1[5] <= 'd0;
		temp_pink1[6] <= 'd0;
		temp_pink1[7] <= 'd0;
		temp_pink1[8] <= 'd0;
		temp_pink1[9] <= 'd0;
		temp_pink1[10] <= 'd0;
		temp_pink1[11] <= 'd0;
		temp_pink1[12] <= 'd0;
		temp_pink1[13] <= 'd0;
		temp_pink1[14] <= 'd0;
		temp_pink1[15] <= 'd0;
		temp_pink1[16] <= 'd0;
		temp_pink1[17] <= 'd0;
		temp_pink1[18] <= 'd0;
		temp_pink1[19] <= 'd0;
		temp_pink1[20] <= 'd0;
		temp_pink1[21] <= 'd0;
		temp_pink1[22] <= 'd0;
		temp_pink1[23] <= 'd0;
		temp_pink1[24] <= 'd0;
		temp_pink1[25] <= 'd0;
		temp_pink1[26] <= 'd0;
		temp_pink1[27] <= 'd0;
		temp_pink1[28] <= 'd0;
		temp_pink1[29] <= 'd0;
		temp_pink1[30] <= 'd0;
		temp_pink1[31] <= 'd0;
		temp_pink2[0] <= 'd0;
		temp_pink2[1] <= 'd0;
		temp_pink2[2] <= 'd0;
		temp_pink2[3] <= 'd0;
		temp_pink2[4] <= 'd0;
		temp_pink2[5] <= 'd0;
		temp_pink2[6] <= 'd0;
		temp_pink2[7] <= 'd0;
		temp_pink2[8] <= 'd0;
		temp_pink2[9] <= 'd0;
		temp_pink2[10] <= 'd0;
		temp_pink2[11] <= 'd0;
		temp_pink2[12] <= 'd0;
		temp_pink2[13] <= 'd0;
		temp_pink2[14] <= 'd0;
		temp_pink2[15] <= 'd0;
		temp_pink2[16] <= 'd0;
		temp_pink2[17] <= 'd0;
		temp_pink2[18] <= 'd0;
		temp_pink2[19] <= 'd0;
		temp_pink2[20] <= 'd0;
		temp_pink2[21] <= 'd0;
		temp_pink2[22] <= 'd0;
		temp_pink2[23] <= 'd0;
		temp_pink2[24] <= 'd0;
		temp_pink2[25] <= 'd0;
		temp_pink2[26] <= 'd0;
		temp_pink2[27] <= 'd0;
		temp_pink2[28] <= 'd0;
		temp_pink2[29] <= 'd0;
		temp_pink2[30] <= 'd0;
		temp_pink2[31] <= 'd0;
		D1 <= 'd0;
		D2 <= 'd0;
		D3 <= 'd0;
	end
	else begin
		case(state)
			LOAD: begin
				if(count_row == 'd0)
					temp_pink1[0] <= in_data;
				else if(count_row == 'd1)
					temp_pink2[0] <= in_data;
				else begin
					temp_pink1[0] <= temp_pink2[0];
					temp_pink2[0] <= in_data;
				end
			end
			OUT_PINK: begin
				if(count_row == 'd1)
					temp_pink1[count_column + 1] <= in_data;
				else if(count_row == 'd2)
					temp_pink2[count_column + 1] <= in_data;
				else begin
					temp_pink1[count_column + 1] <= temp_pink2[count_column + 1];
					temp_pink2[count_column + 1] <= in_data;
				end
			end
			OUT_BLUE: begin
				if(temp_pink1[count_column] >=  temp_pink2[count_column + 2])
					D1 <= temp_pink1[count_column] - temp_pink2[count_column + 2];
				else
					D1 <= temp_pink2[count_column + 2] - temp_pink1[count_column];
				
				if(temp_pink1[count_column + 1] >= temp_pink2[count_column + 1])
					D2 <= temp_pink1[count_column + 1] - temp_pink2[count_column + 1];
				else
					D2 <= temp_pink2[count_column + 1] - temp_pink1[count_column + 1];
				
				if(temp_pink1[count_column + 2] >= temp_pink2[count_column])
					D3 <= temp_pink1[count_column + 2] - temp_pink2[count_column];
				else
					D3 <= temp_pink2[count_column] - temp_pink1[count_column + 2];
			end
			default: begin
				D1 <= D1;
				D2 <= D2;
				D3 <= D3;
			end
		endcase
	end 
end
//output
always @(*) begin
	case(state)
		IDLE: begin
			req = 1'b0;
			wen = 1'b0;
			done = 1'b0;
		end
		LOAD: begin
			req = 1'b1;
			wen = 1'b0;
			done = 1'b0;
		end
		OUT_PINK: begin
			req = 1'b0;
			wen = 1'b1;
			done = 1'b0;
			addr = (count_row << 6) + count_column - 'd64;
			if(count_row == 'd1)
				data_wr = temp_pink1[count_column]; 
			else 
				data_wr = temp_pink2[count_column];  
		end
		OUT_BLUE: begin
			req = 1'b0;
			wen = 1'b1;
			done = 1'b0;
			addr = (count_row << 6) + count_column - 'd96;
			if(count_column == 'd0) begin
				data_wr = (temp_pink1[0] + temp_pink2[0]) / 2;
			end
			else if(count_column == 'd31) begin
				data_wr = (temp_pink1[31] + temp_pink2[31]) / 2;
			end
			else begin
				if((D2 <= D1) && (D2 <= D3))
					data_wr = (temp_pink1[count_column]+ temp_pink2[count_column]) / 2;
				else if((D1 <= D2) && (D1 <= D3))
					data_wr = (temp_pink1[count_column - 1] + temp_pink2[count_column + 1]) / 2;
				else
					data_wr = (temp_pink1[count_column + 1]+ temp_pink2[count_column - 1]) / 2;
			end
		end
		FINISH: begin
			req = 1'b0;
			wen = 1'b0;
			done = 1'b1;
		end
		default: begin
			req = 1'b0;
			wen = 1'b0;
			done = 1'b0;		
		end
	endcase
end
endmodule