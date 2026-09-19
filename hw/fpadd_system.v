/*
 -----------------------------------------------------------------------------
 -- File           : fpadd_system.v
 -----------------------------------------------------------------------------
 */


module fpadd_system (input clk,
                      input rst,
                      input button, 
                      output [7:0] leds, 
                      output an0, output a0, output b0, output c0, output d0, output e0, output f0, output g0,
                      output an1, output a1, output b1, output c1, output d1, output e1, output f1, output g1);

   wire [31:0] fp_out;
   wire rst_debounced;
   wire button_debounced;
   wire [31:0] reg_A, reg_B;
   wire button_pulse;
   wire [63:0] data_out;

   
   debounce db0 (
      .reset(rst),
      .clk(clk),
      .reset_out(rst_debounced)
   );

   // FP addition
   fpadd_pipelined FPA(clk,
                       rst_debounced,
                       reg_A,
                       reg_B,
                       fp_out);

   debounce db1 (
      .reset(button),
      .clk(clk),
      .reset_out(button_debounced)
   );
   
   posedgedet pd0 (
      .clk(clk),
      .signal_in(button_debounced),
      .signal_out(button_pulse)
   );
   
   
   
   memory mem(
      clk,
      rst_debounced,
      button_pulse,
      data_out
   );
   
   assign reg_A = data_out[63:32];
   assign reg_B = data_out[31:0];
   
   assign leds = fp_out[7:0]; 
   
   SSD_driver DRIVER0(clk,
                     rst_debounced,
                     fp_out[31:28],
                     fp_out[27:24],
                     an0, a0, b0, c0, d0, e0, f0, g0);

   SSD_driver DRIVER1(clk,
                     rst_debounced,
                     fp_out[23:20],
                     fp_out[19:16],
                     an1, a1, b1, c1, d1, e1, f1, g1);
endmodule
