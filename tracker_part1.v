module tracker(step_clk, reset, one_Hz_clk, sys_clk, si, bcd3, bcd2, bcd1, bcd0); 
input step_clk, reset, one_Hz_clk, sys_clk;
output si;
output [4:0] bcd3, bcd2, bcd1, bcd0;

reg [30:0] step_counter; 
reg [31:0] shift_register;
reg [30:0] steps_in_one_sec_counter;
reg [30:0] up_to_nine_sec_counter;
reg [3:0] steps_over_32_per_sec_counter;
wire one_Hz_clk_SP, adder_sel, adder_in, clk_sel, first_nine_sec_pulse;
wire [4:0] step_counter_bcd3, step_counter_bcd2, step_counter_bcd1, step_counter_bcd0;
wire [4:0] distance_covered_bcd3, distance_covered_bcd2, distance_covered_bcd1, distance_covered_bcd0; 

//Part 1: Total Step Count
always @(posedge step_clk or posedge reset) 
begin
	if(reset == 1'b1) step_counter <= 31'b0;
	else step_counter <= step_counter + 1;
end

assign si = (step_counter > 9999) ?	1'b1 : 1'b0;
assign step_counter_bcd0 = (step_counter > 9999) ? 5'd9 : (step_counter % 10); 
assign step_counter_bcd1 = (step_counter > 9999) ? 5'd9 : ((step_counter/10) % 10);
assign step_counter_bcd2 = (step_counter > 9999) ? 5'd9 : ((step_counter/100) % 10);
assign step_counter_bcd3 = (step_counter > 9999) ? 5'd9 : ((step_counter/1000) % 10);

assign bcd3 = step_counter_bcd3;
assign bcd2 = step_counter_bcd2;
assign bcd1 = step_counter_bcd1;
assign bcd0 = step_counter_bcd0;


/*
//Part 2: Distance Covered
always @(posedge step_clk)
begin
	shift_register <= {11'b0, step_counter[30:10]}; //right shifts the step_counter by 11 bits	
end													//shift_register will hold the whole number of miles in bits [31:1]
													// and the fractional number of miles in bit 0

//the seven segment displays will show distance covered in the form of 0W_F
// where W is the whole number of miles and F is the fractional number of miles								
assign distance_covered_bcd3 = 5'd0;
assign distance_covered_bcd2 = shift_register[5:1]; //whole number of miles
assign distance_covered_bcd1 = 5'h1F; //TODO: make sure the seven seg display module decodes this as an "_"
assign distance_covered_bcd0 = (shift_register[0] == 1'b1) ? 5'd5 : 5'd0;


//Part 3: Steps Over 32/sec 

single_pulse single_pulser(sys_clk, one_Hz_clk, one_Hz_clk_SP);

always @(posedge step_clk or posedge reset or posedge one_Hz_clk_SP)  //steps in one sec counter
begin
	if(reset == 1'b1) steps_in_one_sec_counter <= 31'b0;
	else if(one_Hz_clk_SP) steps_in_one_sec_counter <= 31'b0;
	else steps_in_one_sec_counter <= steps_in_one_sec_counter + 1;
end

always @(posedge one_Hz_clk_SP or posedge reset) //up to 9 sec counter
begin
	if(reset == 1'b1) up_to_nine_sec_counter <= 31'b0;
	else up_to_nine_sec_counter <= up_to_nine_sec_counter + 1;
end

always @(posedge first_nine_sec_pulse or posedge reset) //how many of first nine secs had activity over 32 steps per sec
begin
	if(reset == 1'b1) steps_over_32_per_sec_counter <= 4'b0;
	else steps_over_32_per_sec_counter <= steps_over_32_per_sec_counter + adder_in;
end

assign adder_sel = (steps_in_one_sec_counter > 32) ? 1'b1 : 1'b0;
assign clk_sel = (up_to_nine_sec_counter < 9) ? 1'b1 : 1'b0;
assign adder_in = adder_sel ? 1'b1 : 1'b0;
assign first_nine_sec_pulse = clk_sel ? one_Hz_clk_SP : 1'b0; 
*/
endmodule 





/*
//Single Pulse
module AND(a, b, out);
input a, b;
output out;

assign out = a & b;

endmodule

module DFF(clk, d, q, q_bar);
input clk, d;
output q, q_bar;

reg q, q_bar;

always @(posedge clk)
begin
  q <= d;
  q_bar <= ~d;
end

endmodule


module debounce(clk, D, SYNCPRESS);
input clk, D;
output SYNCPRESS;

DFF flop1(clk, D, flop1_Q, unused1);
DFF flop2(clk, flop1_Q, SYNCPRESS, unused2);

endmodule


module single_pulse(clk, press, SP);
input clk, press;
output SP;

debounce debouncer(clk, press, sync_press);
DFF flip_flop(clk, sync_press, unused, q_bar);
AND and_gate(sync_press, q_bar, SP);

endmodule
*/