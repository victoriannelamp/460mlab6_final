module pulse_gen_clk_div(clk,rst,start,mode, pulse_out, pulse1, pulsehalf); 
input clk, rst, start; 
input [1:0] mode; 
output reg pulse_out; 
output pulse1, pulsehalf; 

reg [31:0] hybrid;  
reg [31:0] hybrid_cnt; 
reg [31:0] hybrid_loop; 

 
//outputs for all modules 
var_clk_div #(64'd50000000) var_clk_div_1(rst, clk,  pulse1); //1hz
var_clk_div #(64'd100000000) var_clk_div_half(rst, clk, pulsehalf); //halfhz

//choices for mode 
var_clk_div #(64'd1562500) var_clk_div_32(rst, clk,  pulse32); //32hz
var_clk_div #(64'd781250) var_clk_div_64(rst, clk, pulse64); //64hz
var_clk_div #(64'd390625) var_clk_div_128(rst, clk, pulse128); //128hz

//need for hybrid signal 
var_clk_div #(64'd2500000) var_clk_div_20(rst, clk, pulse20); //20hz 
var_clk_div #(64'd1470588) var_clk_div_34(rst, clk, pulse34); //33 ~ 34hz 
var_clk_div #(64'd757575) var_clk_div_66(rst, clk, pulse66); //66hz
var_clk_div #(64'd1923076) var_clk_div_26(rst, clk, pulse26); //26hz
var_clk_div #(64'd714285) var_clk_div_70(rst, clk, pulse70); //70hz
var_clk_div #(64'd1666666) var_clk_div_30(rst, clk,  pulse30); //30hz
var_clk_div #(64'd403225) var_clk_div_124(rst, clk,  pulse124); //124hz

initial 
begin 
/*
hybrid_array[0] <= 64'd2500000; // 20hz 
hybrid_array[1] <= 64'd1470588; //33 ~ 34hz 
hybrid_array[2] <= 64'd757575; //66hz 
hybrid_array[3] <= 64'd1923076; //27 ~ 26hz 
hybrid_array[4] <= 64'd714285; //70hz
hybrid_array[5] <= 64'd1666666; //30hz 
hybrid_array[6] <= 64'd2500000; //19 ~ 20hz 
hybrid_array[7] <= 64'd1666666; //30hz  
hybrid_array[8] <= 64'd1470588; //33 ~ 34hz 
*/
hybrid <=0; 
hybrid_cnt <=0; 
hybrid_loop <= 0; 

end 


// choose output based on mode 
//INPUT mode 
//OUTPUT correct clk_var to varialbe clk generator 
always @(posedge clk)
begin 
case (mode)
	2'b00: begin if(start) pulse_out <= pulse32; else pulse_out <=0;  end //32hz 
	2'b01: begin if(start) pulse_out <= pulse64; else pulse_out <=0;  end  //64hz 
	2'b10: begin if(start) pulse_out <= pulse128; else pulse_out <=0;   end  //128hz  
	2'b11: begin 
			if(start) pulse_out <= hybrid;
		    else pulse_out <= 0; 
		   end 
endcase
end 

always @(posedge pulse1 or posedge rst)
begin 
if(rst) hybrid_cnt <= 0; 
else  hybrid_cnt <= hybrid_cnt + 1; 
end 

//hybrid generate 

always @(posedge clk)
begin 

if(mode == 2'b11)
begin 

if(hybrid_cnt < 9) begin hybrid <= hybrid_loop; end
else if(hybrid_cnt < 73) begin hybrid <= pulse70; end //70hz
else if(hybrid_cnt < 79) begin hybrid <= pulse34;  end //34hz 
else if(hybrid_cnt < 143) begin hybrid <= pulse124;  end //124hz 
else hybrid <= 0; //TODO if hyrbid == 0 don't output anything 

case(hybrid_cnt) 
0: hybrid_loop <= pulse20; 
1: hybrid_loop <= pulse34; 
2: hybrid_loop <= pulse66; 
3: hybrid_loop <= pulse26; 
4: hybrid_loop <= pulse70; 
5: hybrid_loop <= pulse30; 
6: hybrid_loop <= pulse20; 
7: hybrid_loop <= pulse30; 
8: hybrid_loop <= pulse34; 
default: hybrid_loop <= 0; 
endcase 

end 

end 



endmodule 



//varilabe clk generate
//INPUTclk_var 
//OUTPUT clk divided by (clk_var * 2) = pulse  

module var_clk_div(rst, clk, pulse);  
input wire rst, clk; 
output wire pulse; 

reg [31:0] r_reg; 
wire [31:0] r_nxt; 
reg clk_track; 
parameter clk_var = 0; 

assign r_nxt = r_reg+1;   	      
assign pulse = clk_track; 
 
always @(posedge clk)
begin
  if (rst)
     begin
        r_reg <= 0;
	    clk_track <= 1'b1; 
     end
 
  else if (r_nxt == clk_var)
 	   begin
	     r_reg <= 0;
	     clk_track <= ~clk_track;
	   end
 
  else 
      r_reg <= r_nxt;
end


endmodule

