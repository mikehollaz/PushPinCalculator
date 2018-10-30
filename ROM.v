//ROMCOMP
`include "CPU.vh"





module AsyncROM(
	input [7:0] addr,
	output reg [34:0] data
);

always @(addr) begin
	case(addr)

		`RESET + 0: data = set(`DOUT, `N8);
		`RESET + 1: data = set(`STACK0, `N8);
		`RESET + 2: data = set(`STACK1, `N8);
		`RESET + 3: data = set(`STACK2, `N8);
		`RESET + 4: data = set(`STACK3, `N8);
		`RESET + 5: data = set(`STACK_SIZE, `N8);
		`RESET + 6: data = set(`GOUT, `N8);
		`RESET + 7: data = set(`FLAG, `N8);
		`RESET + 8: data = jmp(`WAIT);


		`WAIT + 0: data = acc(`AND, `GOUT, 8'b1111_0000);/*Clears stack led's by and'ing gout with 1111_0000*/
		`WAIT + 1: data = acc(`OR, `GOUT, `STACK_SIZE);/*Display stack size by or'ing gout with stack size*/
		`WAIT + 2: data = atc(3, `PUSH);/*move to PUSH*/
		`WAIT + 3: data = atc(2, `POP);/*move to POP*/
		`WAIT + 4: data = atc(1, `ADD);/*move to ADD*/
		`WAIT + 5: data = atc(0, `MULT);/*move to MULT*/
		`WAIT + 6: data = jmp(`WAIT);/*move to WAIT*/
		
		
		`PUSH + 0: data = clr_bit(`FLAG, `STKOFLW);/*Clear stack overflow led*/
		`PUSH + 1: data = clr_bit(`FLAG, `OFLW);/*Clear arithmetic overflow*/
		`PUSH + 2: data = mov(`STACK2, `STACK3);/*Move stack up*/
		`PUSH + 3: data = mov(`STACK1, `STACK2);
		`PUSH + 4: data = mov(`STACK0, `STACK1);
		`PUSH + 5: data = mov(`DINP, `STACK0);/*Move input to stack 0*/
		`PUSH + 6: data = mov(`STACK0, `DOUT);/*display stack 0*/
		`PUSH + 7: data = set_bit(`GOUT, 3'b111);
		`PUSH + 8: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, 8'd8, `PUSH + 8'd12};/*move if stack overflow overflow*/

		`PUSH + 9: data = {`MOV, `SHL, `REG, `STACK_SIZE, `REG, `STACK_SIZE, `N8};/*Increase stack size*/
		
		`PUSH + 10: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, `N8, `PUSH + 8'd14};/*initil stack*/
		`PUSH + 11: data = jmp(`WAIT);
		
		`PUSH + 12: data = set_bit(`GOUT, 3'd4);/*Turn on stack overflow led*/
		`PUSH + 13: data = jmp(`WAIT);
		`PUSH + 14: data = set(`STACK_SIZE, 8'd1);/*initial stack*/
		`PUSH + 15: data = jmp(`WAIT);



		`POP + 0: data = {`JMP, `EQ, `STACK_SIZE, `NUM, 8'd0, `WAIT};
		`POP + 1: data = clr_bit(`GOUT, 8'd3);
		`POP + 2: data = clr_bit(`GOUT, 8'd4);

		`POP + 3: data = mov(`STACK1, `STACK0);
		`POP + 4: data = mov(`STACK2, `STACK1);
		`POP + 5: data = mov(`STACK3, `STACK2);
		`POP + 6: data = mov(`STACK0, `DOUT);


		`POP + 7: data = {`MOV, `SHR, `REG, `STACK_SIZE, `REG, `STACK_SIZE, `N8};/*shift register 4 to the right?*/

		`POP + 8: data = jmp(`WAIT);





		`ADD + 0: data = clr_bit(`GOUT, `OFLW);/*turn off arithmetic overflow LED*/

		`ADD + 1: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, 8'd 0, `WAIT};
		`ADD + 2: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, 8'd 1, `WAIT};

		`ADD + 3: data = {`ACC, `SAD, `REG, `STACK0, `REG, `STACK1, `N8};
		
		`ADD + 4: data = mov(`STACK0, `DOUT);
		`ADD + 5: data = mov(`STACK2, `STACK1);
		`ADD + 6: data = mov(`STACK3, `STACK2);/*move stack down. JMP to `DOWN*/
		`ADD + 7: data = set(`STACK3,`N8);/*clear 3*/
		
		
		`ADD + 8: data = clr_bit(`GOUT, 3'b011);/*turn off stack overflow LED*/
		
		`ADD + 9: data = {`MOV, `SHR, `REG, `STACK_SIZE, `REG, `STACK_SIZE, `N8};/*shift register 4 to the right*/
		
		`ADD + 10: data = clr_bit(`FLAG, `STKOFLW); /*jump to arithmetic overflow if occurs*/

		`ADD + 11: data = jmp(`WAIT);



		`MULT + 0: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, `N8, `WAIT}; /*empty stack size, jump to wait*/

		`MULT + 1: data = clr_bit(`GOUT, 3'b100);/*turn off arithmetic overflow LED*/

		`MULT + 2: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, 8'd2, `NORMAL};
		`MULT + 3: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, 8'd4, `NORMAL};
		`MULT + 4: data = {`JMP, `EQ, `REG, `STACK_SIZE, `NUM, 8'd8, `NORMAL};


		`MULT + 5: data = set(`STACK0, `N8);
		`MULT + 6: data = set(`DOUT, `N8);/*display 0 on 7-seg display*/
		`MULT + 7: data = jmp(`WAIT);


		`NORMAL + 0: data = {`ACC, `SMT, `REG, `STACK0, `REG, `STACK1, `N8};/*stack 0 = stack 0 * stack 1*/
		`NORMAL + 1: data = clr_bit(`GOUT, 3'b011);/*turn off stack overflow led*/
		`NORMAL + 2: data = atc(`OFLW, `NORMAL + 8'd8);


		`NORMAL + 3: data = mov(`STACK0, `DOUT);/*display stack 0 on 7-seg*/
		`NORMAL + 4: data = mov(`STACK2, `STACK1);
		`NORMAL + 5: data = mov(`STACK3, `STACK2);/*move stack down*/

		`NORMAL + 6: data = {`MOV, `SHR, `REG, `STACK_SIZE, `REG, `STACK_SIZE, `N8};/*shift register 4 to the right*/

		`NORMAL + 7: data = jmp(`WAIT);

	
		`NORMAL + 8: data = set_bit(`FLAG, 3'b100);/*arithmetic overflow on if overflow occurs*/
		`NORMAL + 9: data = jmp(`WAIT);





		default: data = 35'b0; // Default instruction is a NOP
	
	endcase
end
		
		
		// part 10 funcs
		
		function [34:0] set;
			input [7:0] reg_num;
			input [7:0] value;
			set = {`MOV, `PUR, `NUM, value, `REG, reg_num, `N8};
		endfunction
		
		function [34:0] mov;
			input [7:0] src_reg;
			input [7:0] dst_reg;
			mov = {`MOV, `PUR, `REG, src_reg, `REG, dst_reg, `N8};
		endfunction
		
		function [34:0] jmp;
			input [7:0] addr;
			jmp = {`JMP, `UNC, `N10, `N10, addr};
		endfunction
		
		function [34:0] atc;
			input [2:0] bit;
			input [7:0] addr;
			atc = {`ATC, bit, `N10, `N10, addr};
		endfunction
		
		function [34:0] acc;
			input [2:0] op;
			input [7:0] reg_num;
			input [7:0] value;
			acc = {`ACC, op, `REG, reg_num, `NUM, value, `N8};
		endfunction

			// Part 11 funcs
		function [34:0] set_bit;
			input [7:0] reg_num;
			input [2:0] bit;
			set_bit = {`ACC, `OR, `REG, reg_num, `NUM, 8'b1 << bit, `N8};
		endfunction
		
		function [34:0] clr_bit;
			input [7:0] reg_num;
			input [2:0] bit;
			clr_bit = {`ACC, `AND, `REG, reg_num, `NUM, ~(8'b1 << bit), `N8};
		endfunction

endmodule
