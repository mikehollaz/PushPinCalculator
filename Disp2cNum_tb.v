`timescale 1ns/1ns

module Disp2cNum_tb ();
	
	reg [7:0] x;
	reg enable;
	wire [6:0] H0,H1,H2,H3;
	
	Disp2cNum d2tb(x, enable, H0, H1, H2, H3);
	
	initial begin
	
	x = 0;
	enable = 0;
	
	
	//input first number 5
	#100
	enable = 1'b1;
	#100
	x = 8'b0000_0101;
	
	#300
	enable = 1'b0;
	#100
	x = 0;
	
	//input second number 73
	#300 
	enable = 1'b1;
	#100
	x = 8'b0100_1001;
	
	#300
	enable = 1'b0;
	#300
	x = 0;
	
	//input negative number -123
	#300
	enable = 1'b1;
	#100
	x = 8'b1000_0101;
	
	#300 
	enable = 1'b0;
	#300
	x = 0;
	end
	
endmodule
	