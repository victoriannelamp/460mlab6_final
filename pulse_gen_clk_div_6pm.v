module pulse_gen_clk_div(clk,rst,start,mode, pulse, clk_1hz, clk_halfhz); 
input clk, rst, start; 
input [1:0] mode; 
output pulse, clk_1hz, clk_halfhz; 

reg [31:0] clk_var, hybrid;  
reg [31:0] r_reg, r_reg_1hz, r_reg_halfhz;
wire [31:0] r_nxt, r_nxt_1hz, r_nxt_halfhz;
reg clk_track, clk_track_1hz, clk_track_halfhz;
reg [31:0] hybrid_array [10:0]; 
reg [31:0] hybrid_cnt; 
reg [31:0] hybrid_loop; 
reg [7:0] i; 
reg hybrid_sig; 
reg hybrid_rst, hybrid_rst_clr; 


initial 
begin 
hybrid_array[0] <= 64'd2500000; // 20hz 
hybrid_array[1] <= 64'd1470588; //33 ~ 34hz 
hybrid_array[2] <= 64'd757575; //66hz 
hybrid_array[3] <= 64'd1923076; //27 ~ 26hz 
hybrid_array[4] <= 64'd714285; //70hz
hybrid_array[5] <= 64'd1666666; //30hz 
hybrid_array[6] <= 64'd2500000; //19 ~ 20hz 
hybrid_array[7] <= 64'd1666666; //30hz  
hybrid_array[8] <= 64'd1470588; //33 ~ 34hz 
hybrid <=0; 
hybrid_cnt <=0; 
hybrid_loop <= 0; 
i <= 0; 
hybrid_sig <= 0; 
hybrid_rst <= 0; 
hybrid_rst_clr <= 0; 


end 

// choose output based on mode 
//INPUT mode 
//OUTPUT correct clk_var to varialbe clk generator 
always @(posedge clk)
begin 
case (mode)
	2'b00: begin clk_var <= 64'd1562500;  end //32hz 
	2'b01: begin clk_var <= 64'd781250;  end  //64hz 
	2'b10: begin clk_var <= 64'd390625;  end  //128hz  
	2'b11: begin 
			clk_var <= hybrid;
			hybrid_sig <=1; 
		   end 
endcase
end 


//varilabe clk generate
//INPUTclk_var 
//OUTPUT clk divided by (clk_var * 2) = pulse 
 assign r_nxt = r_reg+1;   	      
 assign pulse = (start == 1)? clk_track : 1'b0;
 
always @(posedge clk)
begin
  if (rst || hybrid_rst)
     begin
        r_reg <= 0;
	    clk_track <= 1'b1;
	    hybrid_rst_clr <= 1'b1; 
     end
 
  else if (r_nxt == clk_var)
 	   begin
	     hybrid_rst_clr <= 1'b0; 
	     r_reg <= 0;
	     clk_track <= ~clk_track;
	   end
 
  else 
      r_reg <= r_nxt;
end



//hybrid generate 

always @(posedge clk_1hz)
begin 

if(mode != 2'b11) hybrid_rst<= 0; 

if(mode == 2'b11)
begin 

if(rst == 1 || hybrid_sig == 0) begin hybrid_cnt <= 0; i<= 0; hybrid_rst <= 1; end 
else hybrid_cnt <= hybrid_cnt +1; 

if(hybrid_cnt <= 9) begin hybrid <= hybrid_loop; end
else if(hybrid_cnt < 74) begin hybrid <= 64'd714285; end //70hz
else if(hybrid_cnt < 80) begin hybrid <= 64'd1470588; end //34hz 
else if(hybrid_cnt < 144) begin hybrid <= 64'd403225; end //124hz 
else hybrid <= 0; //TODO if hyrbid == 0 don't output anything 

for(i = 0 ; i < 8'd9; i = i + 1)
begin 
hybrid_loop <= hybrid_array[i];
if(hybrid_rst_clr == 1'b1) hybrid_rst <= 1'b0;
else hybrid_rst <= 1'b1;   
end 

end 

end 




//1Hz clk div
//INPUT clk system 100MHz 
//OUTPUT clk 1hz signal always 
 assign r_nxt_1hz = r_reg_1hz+1;   	      
 assign clk_1hz =  clk_track_1hz; 

always @(posedge clk)
begin 
  if (rst)
     begin
        r_reg_1hz <= 0;
	clk_track_1hz <= 1'b1;
     end
 
  else if (r_nxt_1hz == 64'd50000000) //1hz
 	   begin
	     r_reg_1hz <= 0;
	     clk_track_1hz <= ~clk_track_1hz;
	   end
 
  else 
      r_reg_1hz <= r_nxt_1hz;
end 

//half Hz clk div
//INPUT clk system 100MHz 
//OUTPUT clk halfhz signal always 
 assign r_nxt_halfhz = r_reg_halfhz+1;   	      
 assign clk_halfhz =  clk_track_halfhz; 

always @(posedge clk)
begin 
  if (rst)
     begin
        r_reg_halfhz <= 0;
	clk_track_halfhz <= 1'b1;
     end
 
  else if (r_nxt_halfhz == 64'd100000000) //hlafhz
 	   begin
	     r_reg_halfhz <= 0;
	     clk_track_halfhz <= ~clk_track_halfhz;
	   end
 
  else 
      r_reg_halfhz <= r_nxt_halfhz;
end 


endmodule 

