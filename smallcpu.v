module smallcpu(ALU,clk,PC,IR);

input clk;
output ALU,PC,IR;
reg [15:0] R [0:7]; 
reg [15:0] Memory [0:100];
reg [15:0] PC,IR,MAR,MBR,ALU,I1,I2;
reg [2:0]state;

	// instrctions
	initial begin
	R[1] = 3;
	R[2] = 4; 
	R[3] = 14;
	R[4] = 14;
	Memory[20] = 16'b0001001010000000;// R[0] = R[1] + R[2] = 7
	Memory[21] = 16'b0010001010000000;// R[0] = R[1] - R[2] = -1
	Memory[22] = 16'b0000001010000000;// R[0] = R[1] & R[2] = 0
	Memory[23] = 16'b0100001000000111;// R[0] = [R[1] + Immediate(7) = 10
	Memory[24] = 16'b0011001000000101;// R[0] = R[1] & immediate(5) = 1 
	Memory[25] = 16'b0101001101000101;// load 50 to R[5]
	Memory[26] = 16'b0001001101000000;// R[0] = R[1] + R[5](Loaded form above instrction) =  53
	Memory[27] = 16'b0110010001000101;// store 3 to memory[R[2] + immediate(5)] to memory[9] = 3
	Memory[28] = 16'b0111011100000011;//here we want to make a displacement for pc with 3 so pc after this will = 32 instead of 29
	Memory[32] = 16'b0001001010000000;// R[0] = R[1] + R[2] = 7 to prove that pc = 32
	Memory[33] = 16'b1000001010000100;//pc = pc + immediate(4)
	Memory[38] = 16'b0100001000000110;// R[0] = R[1] + Immediate(6) = 9
	Memory[39] = 16'b1001000000111111;// PC = immediate	(63)
	Memory[63] = 16'b0100001000000111;// R[0] = R[1] + Immediate(7) = 10
	
		
	 
	Memory[8] = 50;
	PC = 20;
	state = 0;
	end
	
always @(posedge clk)
begin
case (state)

//fetch
	0:begin
	MAR = PC;
	MBR = Memory[MAR];
	IR = MBR;
	PC = PC + 1;
	state = 1;
	end
	
	//decode
	1:begin
		case (IR[15:12])
		0,1,2: begin	MAR = R[IR[11:3]]; end
		3,4,5,6,7,8: begin  MAR = R[IR[11:9]]; end
		endcase
		state = 2;
		end
	
	//operand fetch
	2: begin 
			case(IR[15:12])
				0,1,2,6,7,8:begin I1 = R[IR[11:9]]; I2 = R[IR[8:6]]; end
				5,6 :begin I1 = R[IR[11:9]]; I2 =  R[IR[8:6]];
					MBR = Memory[MAR + IR[5:0]];
					end
					endcase
					state = 3;
					end

	//excute				
	3:begin
			case (IR[15:12])
				0:begin ALU = I1 & I2; end
				1:begin ALU = I1 + I2; end
				2:begin ALU = I1 - I2; end
				3:begin ALU = I1 & IR[5:0]; end
				4:begin ALU = I1 + IR[5:0]; end
	         5:begin ALU = MBR; end
			   6:begin MBR = I2;ALU = MBR; end
			   7:begin if (I1 == I2) PC = PC + IR[5:0];end
				8:begin if (I1!= I2) PC = PC + IR[5:0];end
				9:begin PC = IR[11:0]; end
			endcase
			state = 4;
		end
		
		//store	
		4:begin 
			case(IR[15:12])
				0,1,2: begin R[IR[5:3]] = ALU; end
				3,4,5: begin R[IR[8:6]] = ALU; end
				6: begin  Memory[MAR] = MBR; end
			endcase
			state = 0;
		end	
 	endcase
	end
	endmodule
	
	
	

	