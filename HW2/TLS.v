module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output          Gout;
output          Yout;
output          Rout;
parameter G=0, Y=1, R=2;
reg [1:0] state, next_state;
reg [3:0] counter;
reg [3:0] temp_Gin, temp_Yin, temp_Rin;
always @(*) begin
	if(Set)
		next_state = G;
	else if(Stop)
		next_state = state;
	else if(Jump)
		next_state = R;
	else begin
		case(state)
			G: begin
				if(counter == temp_Gin)
					next_state = Y;
				else
					next_state = state;
			end
			Y:
				if(counter == temp_Yin)
					next_state = R;
				else
					next_state = state;
			R:
				if(counter == temp_Rin)
					next_state = G;
				else
					next_state = state;
			default:
				next_state = state;
		endcase
	end
end
always @(posedge clk, posedge reset) begin
	if(reset) begin
		state <= G;
		temp_Gin <= 4'b0;
		temp_Yin <= 4'b0;
		temp_Rin <= 4'b0;
		counter <= 4'b0;
	end
	else begin
		state <= next_state;
		temp_Gin <= Gin;
		temp_Yin <= Yin;
		temp_Rin <= Rin;
		if(Set)
			counter <= 1'd1;
		else if(Stop)
			counter <= 1'd1;
		else if(Jump)
			counter <= 1'd1;
		else begin
			case(state)
				G: begin
					if(counter == temp_Gin)
						counter <= 1'd1;
					else
						counter <= counter + 1'd1;
				end
				Y: begin
					if(counter == temp_Yin)
						counter <= 1'd1;
					else
						counter <= counter + 1'd1;
				end
				R: begin
					if(counter == temp_Rin)
						counter <= 1'd1;
					else
						counter <= counter + 1'd1;
				end
				default:
					counter <= 1'd1;
			endcase
		end
	end
end
always @(*) begin
	case(state)
		G: begin
			Gout = 1'b1;
			Yout = 1'b0;
			Rout = 1'b0;
		end
		Y: begin
			Gout = 1'b0;
			Yout = 1'b1;
			Rout = 1'b0;	
		end
		R: begin
			Gout = 1'b0;
			Yout = 1'b0;
			Rout = 1'b1;	
		end
		default: begin
			Gout = 1'b0;
			Yout = 1'b0;
			Rout = 1'b0;
		end
	endcase
end
endmodule