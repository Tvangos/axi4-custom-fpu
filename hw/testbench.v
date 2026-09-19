`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTH
// Design Name: 
// Module Name:    testbench
// Project Name: Floating Point Adder- testbench
// Target Devices: Zedboard 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define CYCLE 10

module testbench;
	parameter NUM = 10;  // This is the number of entries in the input file: number of FP additions 
	reg	clk, rst;
	wire [7:0] leds;
	wire an0, a0, b0, c0, d0, e0, f0, g0;
	wire an1, a1, b1, c1, d1, e1, f1, g1;
	
	initial
		begin
			clk=0;
			rst=0;
			#(`CYCLE) rst = 1;
			#(`CYCLE) rst = 0;
			$display ("Testbench is running...\n");
			 #(`CYCLE*100) $display ("Testbench finished.\n");
			$finish;
		end
	
	always
		begin
			#(`CYCLE/2) clk=~clk;
		end
		
	fpadd_system fpsystem(clk,
                      	rst,  
                      	leds,
                      	an0, a0, b0, c0, d0, e0, f0, g0,
                      	an1, a1, b1, c1, d1, e1, f1, g1);
		
endmodule