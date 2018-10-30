`include "CPU.vh"

// CPU Module

module CPU(Btns, Clk, Din, Reset, Sample, Turbo, Debug, Dout, Dval, GPO, IP);
	
	input  Clk, Reset, Sample, Turbo;
	input  [2:0] Btns;
	input  [7:0] Din;
	output  [3:0] Debug;
	output  [7:0] Dout;
	output    Dval;
	output  [5:0] GPO;
	output reg [7:0] IP;
	
	integer j;
	
	wire [7:0] din_safe;
	wire [3:0] pb_safe;
	wire [3:0] pb_activated;
	wire turbo_safe;
	wire [34:0] instruction;
	
	
	
	// Registers
	reg [7:0] Reg [0:31];
	reg [7:0] cnum;
	reg [15:0] word;
	reg signed [15:0] s_word;
	reg [7:0] cloc;
	reg cond;
	reg [23:0] cnt;
	
	// Use these to Read the Special Registers
	wire [7:0] Rgout = Reg[29];
	wire [7:0] Rdout = Reg[30];
	wire [7:0] Rflag = Reg[31];
	
	
	Synchroniser tbo(Clk, Turbo, turbo_safe);
	
	//Synchronise CPU operations to when cnt == 0
	wire go = !Reset && ((cnt == 0) || turbo_safe);
	
	
	initial IP <= 8'b0;
	initial cnt <= 24'b0;
	
	// D_in Safe assignments
	
	
	Synchroniser din_safe0(Clk, Din[0], din_safe[0]);
	Synchroniser din_safe1(Clk, Din[1], din_safe[1]);
	Synchroniser din_safe2(Clk, Din[2], din_safe[2]);
	Synchroniser din_safe3(Clk, Din[3], din_safe[3]);
	Synchroniser din_safe4(Clk, Din[4], din_safe[4]);
	Synchroniser din_safe5(Clk, Din[5], din_safe[5]);
	Synchroniser din_safe6(Clk, Din[6], din_safe[6]);
	Synchroniser din_safe7(Clk, Din[7], din_safe[7]);
	
	// pb_safe assignments
	
	Synchroniser pb_safe3(Clk, Sample, pb_safe[3]);
	Synchroniser pb_safe2(Clk, Btns[2], pb_safe[2]);
	Synchroniser pb_safe1(Clk, Btns[1], pb_safe[1]);
	Synchroniser pb_safe0(Clk, Btns[0], pb_safe[0]);
	
	
		
	
	
	// Use these to Write to the Flags and Din Registers
	`define RFLAG Reg[31]
	`define RDINP Reg[28]
	
	// Connect certain registers to the external world
	assign Dout = Rdout;
//	assign GPO = Rgout[5:0];
	
	assign GPO[3:0] = Reg[`STACK_SIZE][3:0];
	assign GPO[4] = `RFLAG[`STKOFLW];
	assign GPO[5] = `RFLAG[`OFLW];
	

	assign Dval = Rgout[`DVAL];
//	initial Dval = 1;
		
	// Debugging assignments â€“ you can change these to suit yourself
	assign Debug[3] = Rflag[`SHFT];
	assign Debug[2] = Rflag[`OFLW];
	assign Debug[1] = Rflag[`SMPL];
	assign Debug[0] = go;
		
	


		//Part 12.3
	genvar i;
	
	
	generate
		for(i=0; i<=3; i=i+1) begin :pb
			DetectFallingEdge dfe(Clk, pb_safe[i], pb_activated[i]);
		end
	
	endgenerate
	
	
	
	//Clock circuitry (250ms cycle)
	
	localparam CntMax = 24'd12500000;
	
	always @(posedge Clk)
		cnt <= (cnt == CntMax) ? 0 : cnt+1;
		
	
	

	
		
	//Program Memory
	
	AsyncROM Pmem(IP, instruction);
		

	
	
	
	

	// Instruction Cycle
	wire [3:0] cmd_grp = instruction[34:31];
	wire [2:0] cmd = instruction[30:28];
	wire [1:0] arg1_typ = instruction[27:26];
	wire [7:0] arg1 = instruction[25:18];
	wire [1:0] arg2_typ = instruction[17:16];
	wire [7:0] arg2 = instruction[15:8];
	wire [7:0] addr = instruction[7:0];
	
	always @(posedge Clk) begin
		if (go) begin
			IP <= IP + 8'b1; // Default action is to increment IP
				case (cmd_grp)
					`MOV: begin
						cnum = get_number(arg1_typ,arg1);
						case (cmd)
							`SHL: begin
								`RFLAG[`SHFT] <= cnum[7];
								cnum = {cnum[6:0],1'b0};
							end
							`SHR: begin
								`RFLAG[`SHFT] <= cnum[0];
								cnum = {1'b0, cnum[7:1]};
							end
						endcase
											
						Reg[get_location(arg2_typ, arg2)] <= cnum;
					end
					
					`JMP: begin
						case (cmd)
							`UNC: cond = 1;
							`EQ: cond = ( get_number(arg1_typ, arg1) == get_number(arg2_typ, arg2) );
							`ULT: cond = ( get_number(arg1_typ, arg1) < get_number(arg2_typ, arg2) );
							`SLT: cond = ( $signed(get_number(arg1_typ, arg1)) < $signed(get_number(arg2_typ, arg2)) );
							`ULE: cond = ( get_number(arg1_typ, arg1) <= get_number(arg2_typ, arg2) );
							`SLE: cond = ( $signed(get_number(arg1_typ, arg1)) <= $signed(get_number(arg2_typ, arg2)) );
							default: cond = 0;
							endcase
							if (cond) IP <= addr;
					end
				
					`ACC: begin
						cnum = get_number(arg2_typ,arg2);
						cloc = get_location(arg1_typ,arg1);
						case (cmd)
							`UAD: word = Reg[cloc] + cnum;
							`SAD: s_word = $signed(Reg[cloc]) + $signed(cnum);
							`UMT: word = Reg[cloc] * cnum;
							`SMT: s_word = $signed(Reg[cloc]) * $signed(cnum);
							`AND: cnum = Reg[cloc] & cnum;
							`OR: cnum = Reg[cloc] | cnum;
							`XOR: cnum = Reg[cloc] ^ cnum;
						endcase
						if (cmd[2] == 0)
							if (cmd[0] == 0) begin //Unsigned addition or multiplication
								cnum = word[7:0];
								`RFLAG[`OFLW] <= (word > 255);
							end
							else begin //Signed addition or multiplication
								cnum = s_word[7:0];
								`RFLAG[`OFLW] <= (s_word > 127 || s_word <-128);
							end
						Reg[cloc] <= cnum;
					end
				
					`ATC: begin
						if (`RFLAG[cmd]) IP <= addr;
						`RFLAG[cmd] <= 0;
					end
		
				endcase
		end
		// Place reset code hereâ€¦
		if (Reset) begin
			IP <= 8'b0;
			`RFLAG <= 'b0;
			end
			else begin
//				for(j=0; j<=3; j=j+1)
					if (pb_activated[0]) `RFLAG[0] <= 1;
					if (pb_activated[1]) `RFLAG[1] <= 1;
					if (pb_activated[2]) `RFLAG[2] <= 1;
					if (pb_activated[3]) `RFLAG[3] <= 1;
					
				if (pb_activated[3]) `RDINP <= din_safe;
			end
	end

	
		
	function [7:0] get_number;
		input [1:0] arg_type;
		input [7:0] arg;
		begin
			case (arg_type)
				`REG: get_number = Reg[arg[5:0]];
				`IND: get_number = Reg[Reg[arg[5:0]][5:0]];
				default: get_number = arg;
			endcase
		end
	endfunction
	
	function [5:0] get_location;
		input [1:0] arg_type;
		input [7:0] arg;
		begin
			case (arg_type) 
				`REG: get_location = arg[5:0];
				`IND: get_location = Reg[arg[5:0]][5:0];
				default: get_location = 0;
			endcase
		end
	endfunction
	
	

	
	
endmodule
	