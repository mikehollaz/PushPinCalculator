`timescale 1ns/1ns

module MyComputer_tb;

	reg 		          		CLOCK_50;

	//////////// SEG7 //////////
	wire		     [6:0]		HEX0;
	wire		     [6:0]		HEX1;
	wire		     [6:0]		HEX2;
	wire		     [6:0]		HEX3;
	wire		     [6:0]		HEX4;
	wire		     [6:0]		HEX5;

	//////////// KEY //////////
	reg 		     [3:0]		KEY;

	//////////// LED //////////
	wire		     [9:0]		LEDR;

	//////////// SW ///////////
	reg 		     [9:0]		SW;
	
	MikeComp TestComputer(.CLOCK_50(CLOCK_50), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .KEY(KEY), .LEDR(LEDR), .SW(SW));
	
	wire[6:0] output0;
	wire[6:0] output1;
	wire[6:0] output2;
	wire[6:0] output3;
	wire[6:0] output4;
	wire[6:0] output5;
	
	SSeg_inv a(HEX0, output0);
	SSeg_inv b(HEX1, output1);
	SSeg_inv c(HEX2, output2);
	SSeg_inv d(HEX3, output3);
	SSeg_inv e(HEX4, output4);
	SSeg_inv f(HEX5, output5);
	
	initial begin
		CLOCK_50 = 0;
		KEY = 0;
		SW = 0;
		
		// Push 5		
		#300
		SW[0] <= 1'b1;
		SW[2] <= 1'b1;	
		#100
		KEY[3] <= 1'b1;	
		#200		
		KEY[3] <= 'b0;	
		#200		
		SW <= 0;		
		
		// Push 73	
		#300
		SW[0] <= 1'b1;
		SW[3] <= 1'b1;
		SW[6] <= 1'b1;
		#200		
		KEY[3] <= 1'b1;
		#200	
		KEY[3] <= 'b0;	
		#200		
		SW <= 0;
		
		// Pop	
		#300
		KEY[2] <= 1'b1;
		#200
		KEY[2] <= 1'b0;
		
		// Pop	
		#300
		KEY[2] <= 1'b1;
		#200
		KEY[2] <= 1'b0;
		
		
		// Push -1		
		#1000
		SW <= 8'b1111_1111;
		#200		
		KEY[3] <= 1'b1;	
		#200		
		KEY[3] <= 1'b0;	
		#200		
		SW <= 0;
		
		// Push -5
		#300
		SW <= 8'b1111_1011;	
		#200		
		KEY[3] <= 1'b1;	
		#200		
		KEY[3] <= 1'b0;	
		#200		
		SW <= 0;
		
		// Mult
		#1000	
		KEY[0] <= 1'b1;	
		#200		
		KEY[0] <= 1'b0;	
		#200		
		SW <= 0;
		
		// Push 8
		#300
		SW <= 8'b0000_1000;	
		#200		
		KEY[3] <= 1'b1;	
		#200		
		KEY[3] <= 1'b0;	
		#200		
		SW <= 0;
		
		// Add
		#1000	
		KEY[1] <= 1'b1;	
		#200		
		KEY[1] <= 'b0;	
		#200		
		SW <= 0;
		
	end
	
	always
		#2 CLOCK_50 <= !CLOCK_50;
		
endmodule

module SSeg_inv(input [6:0] bin, output reg [6:0] num);
	always @(*) begin
				case (bin)
					7'b011_1111: num = 7'b111_1111;
					7'b111_1111: num = 7'b011_1111;
					7'b100_0000: num = 0;
					7'b111_1001: num = 1;
					7'b010_0100: num = 2;
					7'b011_0000: num = 3;
					7'b001_1001: num = 4;
					7'b001_0010: num = 5;
					7'b000_0010: num = 6;
					7'b111_1000: num = 7;
					7'b000_0000: num = 8;
					7'b001_1000: num = 9;
					7'b000_1000: num = 10;
					7'b000_0011: num = 11;
					7'b100_0110: num = 12;
					7'b010_0001: num = 13;
					7'b000_0110: num = 14;
					7'b000_1110: num = 15;
				endcase
	end
endmodule
	
	
	