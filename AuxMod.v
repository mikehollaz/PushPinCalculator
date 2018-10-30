// Add more auxillary modules here...



// Display a Hexadecimal Digit, a Negative Sign, or a Blank, on a 7-segment Display
module SSeg(input [3:0] bin, input neg, input enable, output reg [6:0] segs);
	always @(*)
		if (enable) begin
			if (neg) segs = 7'b011_1111;
			else begin
				case (bin)
					0: segs = 7'b100_0000;
					1: segs = 7'b111_1001;
					2: segs = 7'b010_0100;
					3: segs = 7'b011_0000;
					4: segs = 7'b001_1001;
					5: segs = 7'b001_0010;
					6: segs = 7'b000_0010;
					7: segs = 7'b111_1000;
					8: segs = 7'b000_0000;
					9: segs = 7'b001_1000;
					10: segs = 7'b000_1000;
					11: segs = 7'b000_0011;
					12: segs = 7'b100_0110;
					13: segs = 7'b010_0001;
					14: segs = 7'b000_0110;
					15: segs = 7'b000_1110;
				endcase
			end
		end
		else segs = 7'b111_1111;
endmodule

module Debounce(input clock, input source, output reg debounced);
    parameter COUNT_LIMIT = /*1500000*/ 4;    // Slows down the clock
    wire synced; // Synchronised input
    reg previous_val;
    reg [20:0] count;
	 
	 initial count <= 0;
	 
    Synchroniser sync(clock,source,synced);// Instantiate a synchroniser for the input
   
    always @(posedge clock)
    begin
        if (synced!=previous_val)           // Reset count if current value is not the same as the last one
        begin
            count <= 0;
        end
        else if (count == COUNT_LIMIT)      // If count reaches the limit, then push input through to output
        begin
            debounced<=synced;
            count <= 0;
        end
        else
        begin
            count <= count + 21'b1;             //Increment count
        end
        previous_val<=synced;                   //Set previous state to current state
    end
 
endmodule



module Disp2cNum(input signed [7:0] x, input enable, output [6:0] H0, H1, H2, H3);
	wire neg = (x < 0);
	wire [7:0] ux = neg ? -x : x;
	wire[7:0] xo0, xo1, xo2, xo3;
	wire eno0, eno1, eno2, eno3;
	
	// You fill in the rest: create four instances of DispDec);
	
	DispDec dd0(ux, neg, enable, xo0, eno0, H0);
	DispDec dd1(xo0, neg, eno0, xo1, eno1, H1);
	DispDec dd2(xo1, neg, eno1, xo2, eno2, H2);
	DispDec dd3(xo2, neg, eno2, xo3, eno3, H3);

endmodule

module DispDec(input signed [7:0] x, input neg, enable, output reg [7:0] xo, output reg eno, output [6:0] segs);
	wire [3:0] digit;
	wire n = (x==0 & neg) ? 1'b1:1'b0;
	
	SSeg converter(digit, n, enable, segs);
	
	// You fill in the rest. Only a few lines of code are required.
	
	assign digit = x % 10;
//	
//	always @(*) begin
//		if (enable == 0) 
//			eno = 0;
//		else begin
//			if (x == 0 & !neg | n) 
//				eno = 0;
//			else eno = 1;
//		end
//		
//	end
//	
//	always @(*) begin
//		xo = x/10;
//	end
	
	always @(*) begin
	 xo = x/10;
	 case (neg)
		0: eno = (x/10 == 0) ? 1'd0 : 1'd1;
		1: eno = (x == 0) ? 1'd0 : 1'd1;
	endcase
	end

endmodule


module DispHex(input [7:0] x, output [6:0] H4, H5);
	
	SSeg sseg_1(x[3:0], 1'b0, 1'b1, H4);
	SSeg sseg_2(x[7:4], 1'b0, 1'b1, H5);
	
endmodule


module Synchroniser(input clk, Synch_x, output Synch_y);
	
	wire in_between;
	wire exit;
	
	flip_flop first(Synch_x, clk, in_between);
	flip_flop second(in_between, clk, exit);
	
	assign Synch_y = exit;
	
endmodule


module flip_flop(input D, input clk, output reg Q);
	
	always @(posedge clk) begin
		Q = D;
	end
endmodule

module DetectFallingEdge(input clk, btn_sync, output fallen);
	
	reg  btn_sync_old;

	
	always @(posedge clk)
			btn_sync_old <= btn_sync;
			
	assign fallen = (!btn_sync && btn_sync_old);
			
		
	
	
endmodule
