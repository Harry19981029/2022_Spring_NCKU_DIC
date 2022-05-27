module BOE(clk, rst, data_num, data_in, result);
input clk;
input rst;
input [2:0] data_num;
input [7:0] data_in;
output [10:0] result;

reg [1:0] state, next_state;
reg [7:0] temp [5:0];
reg [2:0] data_num_temp;
reg [2:0] count;
reg [7:0] max;
reg [10:0] sum;
reg [10:0] result;
parameter IDLE = 0, MAX = 1, SUM = 2, SORT = 3; 

always@(*) begin
    case(state)
	    IDLE: begin
			if(count == data_num_temp)
				next_state = MAX;
			else
				next_state = IDLE;
		end
		MAX: 
		    next_state = SUM;
		SUM:
		    next_state = SORT;
		SORT: begin
			if(count == data_num_temp)
				next_state = IDLE;
			else
				next_state = SORT;
		end
	endcase
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    state <= IDLE;
	end
	else begin
	    state <= next_state;
	end
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    data_num_temp <= 'd7;
	end
	else begin
	    if(state == IDLE) begin
			if(data_num != 0)
				data_num_temp <= data_num - 'd1;
			else
				data_num_temp <= data_num_temp;
		end
	end
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    count <= 'd0;
	end
	else begin
	    if(state == IDLE || state == SORT) begin
			if(count == data_num_temp)
				count <= 0;
			else
				count <= count + 1;
		end
		else
			count <= 'd0;
	end
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    sum <= 'd0;
	end
	else begin
	    if(state == IDLE) begin
			sum <= sum + data_in;
		end
		else if(state == SORT) begin
			sum <= 'd0;
		end
		else
			sum <= sum;
	end
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    max <= 'd0;
	end
	else begin
	    if(state == IDLE) begin
			if(data_in > max) begin
				max <= data_in;
			end
		end
		else if(state == SORT) begin
			max <= 'd0;
		end
		else
			max <= max;
	end
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    temp[0] <= 255;
		temp[1] <= 255;
		temp[2] <= 255;
		temp[3] <= 255;
		temp[4] <= 255;
		temp[5] <= 255;
	end
	else begin
		if(state == IDLE) begin
			if(data_in <= temp[0]) begin
			    temp[0] <= data_in;
				temp[1] <= temp[0];
				temp[2] <= temp[1];
				temp[3] <= temp[2];
				temp[4] <= temp[3];
				temp[5] <= temp[4];
			end
			else if(data_in <= temp[1]) begin
				temp[1] <= data_in;
				temp[2] <= temp[1];
				temp[3] <= temp[2];
				temp[4] <= temp[3];
				temp[5] <= temp[4];
			end
			else if(data_in <= temp[2]) begin
				temp[2] <= data_in;
				temp[3] <= temp[2];
				temp[4] <= temp[3];
				temp[5] <= temp[4];
			end
			else if(data_in <= temp[3]) begin
				temp[3] <= data_in;
				temp[4] <= temp[3];
				temp[5] <= temp[4];
			end
			else if(data_in <= temp[4]) begin
				temp[4] <= data_in;
				temp[5] <= temp[4];
			end
			else begin
			    temp[5] <= data_in;
			end
		end
		else if(state == SORT) begin
			if(count == data_num_temp) begin
				temp[0] <= 'd255;
				temp[1] <= 'd255;
				temp[2] <= 'd255;
				temp[3] <= 'd255;
				temp[4] <= 'd255;
				temp[5] <= 'd255;
			end
			else begin
				temp[0] <= temp[0];
				temp[1] <= temp[1];
				temp[2] <= temp[2];
				temp[3] <= temp[3];
				temp[4] <= temp[4];
				temp[5] <= temp[5];
			end
		end
	end
end

always @(posedge clk or posedge rst) begin
	case(state)
		IDLE: begin
			result <= 'd0;
		end
		MAX: begin
			result <= max;
		end
		SUM: begin
			result <= sum;
		end
		SORT: begin
			result <= temp[count];
		end
	endcase
end
endmodule