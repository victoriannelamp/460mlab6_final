module top(clk, rst,start,mode, si, a,b,c,d,e,f,g,an); 
input clk,rst,start; 
input [1:0] mode; 
output si, a, b, c, d, e, f, g; //segments 
output [3:0] an; 
wire clk_1hz, pulse; 
wire [4:0] bcd0, bcd1, bcd2, bcd3;  //the 4 inputs for each display
wire dp; 

//generate pulse and 1hz clk
pulse_gen_clk_div pulse_clk_div_inst(clk,rst,start,mode, pulse, clk_1hz);

//fitbit module pass bcd values to output 
tracker tracker_inst(pulse, rst, clk_1hz, sys_clk, si, bcd3, bcd2, bcd1, bcd0); 

//seven seg output 
seven_seg_display seven_seg_display_inst( clk, bcd0, bcd1, bcd2, bcd3, a, b, c, d, e, f, g, dp, an);

endmodule 