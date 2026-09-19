`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTH
// 
// Design Name: 
// Module Name:   fpadd_pipelined
// Project Name: 32 bit Floating Point Unit - Add
// Target Devices: Zedboard
// Tool versions: Vivado 2020.2
//
// Description: 32-bit FP adder with a 2 pipeline stages
//  The module does not check the input for subnormal and NaN numbers, 
//  and assumes that the two inputs are normal FP32 numbers with 0<exp<255.
//  We also assume that the output does not overflow or undeflow, so there is no need to check for these conditions.
//  An FP32 number has 1 sign bit, 8 exponent bits(biased by 127), and 23 mantissa bits.
//////////////////////////////////////////////////////////////////////////////////
module fpadd_pipelined (input clk,
                     	input reset,
                     	input [31:0] reg_A, 
                     	input [31:0] reg_B,  
		     			output reg[31:0] out);
	
	reg [31:0] A, B, result; 
	reg signA, signB; 
	reg [7:0] expA, expB; 
	reg [23:0] mantA, mantB;
	
	reg [7:0] res_exp;
	reg [24:0] big_mant, small_mant, res_mant, res_mant_shifted; 
	reg [24:0] new_mantA, new_mantB;
	
	integer k;
	reg [4:0] lz_count;

	// stored in flip flop for pipeline logic
	reg signA_ff, signB_ff; 
	reg [7:0] res_exp_ff;
	reg [24:0] res_mant_ff; 
	reg [24:0] new_mantA_ff, new_mantB_ff;

	// Register the two inputs, and use A and B in the combinational logic. 
	always @ (posedge clk or posedge reset)
		begin
			if (reset == 1'b1)
				begin
					out <= 32'b0;
					A <= 0;
					B <= 0;
				end			
			else
				begin
					A <= reg_A;
					B <= reg_B;
					out <= result;
				end
		end
	
	// flip flop for seperating stages
	always @(posedge clk or posedge reset) begin
		if (reset == 1'b1)
			begin
				signA_ff <= 0;
				signB_ff <= 0;
				res_exp_ff <= 0;
				res_mant_ff <= 0;
				new_mantA_ff <= 0;
				new_mantB_ff <= 0;
			end			
		else
			begin
				signA_ff <= signA;
				signB_ff <= signB;
				res_exp_ff <= res_exp;
				res_mant_ff <= res_mant;
				new_mantA_ff <= new_mantA;
				new_mantB_ff <= new_mantB;
			end

	end

	// Combinational Logic to (a) compare and adjust the exponents, 
	//                       (b) shift appropriately the mantissa if necessary, 
	//                       (c) add the two mantissas, and
	//                       (d) perform post-normalization. 
	//                           Make sure to check explicitly for zero output. 
	always@(*)
		begin
        	res_mant = 25'b0;
        	res_exp = 8'b0;
        	big_mant = 25'b0;
        	small_mant = 25'b0;
        	new_mantA = 25'b0;
        	new_mantB = 25'b0;

			signA = A[31];
			expA = A[30:23];
			// Add left side 1
			mantA = expA ? {1'b1, A[22:0]} : {1'b0, A[22:0]};

			signB = B[31];
			expB = B[30:23];
			mantB = expB ? {1'b1, B[22:0]} : {1'b0, B[22:0]};

			// shift mantissas
		 	if(expA > expB)
				begin
					res_exp = expA;
					// Add 0 in case of overflow in addition of mantissas. 1x.xx
					new_mantA = {1'b0, mantA};    
					new_mantB = {1'b0, mantB} >> (expA - expB);
				end
			else
				begin
					res_exp = expB;
					new_mantB = {1'b0, mantB};
					new_mantA = {1'b0, mantA} >> (expB - expA);
				end  
				
			if(new_mantA >= new_mantB)
				begin
					big_mant = new_mantA;
					small_mant = new_mantB;
				end
			else
				begin
					big_mant = new_mantB;
					small_mant = new_mantA;
				end

			// Sum mantissas
			if(signA == signB)
				res_mant = big_mant + small_mant;
			else 
				res_mant = big_mant - small_mant;
		end	
		
		always@(*) begin			
			result = 32'b0;
        	lz_count = 5'd0;

			// Normalization
			if (res_mant_ff == 25'd0)
				result = 32'b0;
			else if (res_mant_ff[24])
				begin
					result[22:0] = res_mant_ff[23:1];
					result[30:23] = res_exp_ff + 1'b1;
					result[31] = (new_mantA_ff >= new_mantB_ff) ? signA_ff : signB_ff;
				end
			else
				begin
					// default. no 1 is found
					lz_count = 5'd0;
					if      (res_mant_ff[23]) lz_count = 5'd0;
                    else if (res_mant_ff[22]) lz_count = 5'd1;
                    else if (res_mant_ff[21]) lz_count = 5'd2;
                    else if (res_mant_ff[20]) lz_count = 5'd3;
                    else if (res_mant_ff[19]) lz_count = 5'd4;
                    else if (res_mant_ff[18]) lz_count = 5'd5;
                    else if (res_mant_ff[17]) lz_count = 5'd6;
                    else if (res_mant_ff[16]) lz_count = 5'd7;
                    else if (res_mant_ff[15]) lz_count = 5'd8;
                    else if (res_mant_ff[14]) lz_count = 5'd9;
                    else if (res_mant_ff[13]) lz_count = 5'd10;
                    else if (res_mant_ff[12]) lz_count = 5'd11;
                    else if (res_mant_ff[11]) lz_count = 5'd12;
                    else if (res_mant_ff[10]) lz_count = 5'd13;
                    else if (res_mant_ff[9])  lz_count = 5'd14;
                    else if (res_mant_ff[8])  lz_count = 5'd15;
                    else if (res_mant_ff[7])  lz_count = 5'd16;
                    else if (res_mant_ff[6])  lz_count = 5'd17;
                    else if (res_mant_ff[5])  lz_count = 5'd18;
                    else if (res_mant_ff[4])  lz_count = 5'd19;
                    else if (res_mant_ff[3])  lz_count = 5'd20;
                    else if (res_mant_ff[2])  lz_count = 5'd21;
                    else if (res_mant_ff[1])  lz_count = 5'd22;
                    else if (res_mant_ff[0])  lz_count = 5'd23;	

					res_mant_shifted = res_mant_ff << lz_count;
    				result[22:0] = res_mant_shifted[22:0];
					result[30:23] = res_exp_ff - lz_count;
					result[31] = (new_mantA_ff >= new_mantB_ff) ? signA_ff : signB_ff;
				end
		end
endmodule