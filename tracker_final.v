module tracker(step_clk, reset, one_Hz_clk, half_Hz_clk, sys_clk, si, bcd3, bcd2, bcd1, bcd0); 
input step_clk, reset, one_Hz_clk, sys_clk, half_Hz_clk;
output si;
output [4:0] bcd3, bcd2, bcd1, bcd0;

reg [30:0] step_counter, steps_in_one_sec_counter, second_counter, cont_sec_of_high_activity, display_reg; 
reg [31:0] shift_register;
reg [3:0] steps_over_32_per_sec_counter;
reg [1:0] state, next_state;
reg [4:0] bcd3, bcd2, bcd1, bcd0;
wire one_Hz_clk_SP, adder_sel, adder_in, clk_sel, first_nine_sec_pulse;
wire cont_sec_sel, cont_sec_in, equals_60_sel, greater_than_60_sel;
wire [4:0] step_counter_bcd3, step_counter_bcd2, step_counter_bcd1, step_counter_bcd0;
wire [4:0] distance_covered_bcd3, distance_covered_bcd2, distance_covered_bcd1, distance_covered_bcd0; 
wire [4:0] steps_over_32_bcd3, steps_over_32_bcd2, steps_over_32_bcd1, steps_over_32_bcd0; 
wire [4:0] high_activity_bcd3, high_activity_bcd2, high_activity_bcd1, high_activity_bcd0; 
wire [30:0] display_reg_in;

/*******Part 1: Total Step Count***********/
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



/***********Part 2: Distance Covered**********/
always @(posedge step_clk)
begin
	shift_register <= {11'b0, step_counter[30:10]}; //right shifts the step_counter by 11 bits	
end													//shift_register will hold the whole number of miles in bits [31:1]
													// and the fractional number of miles in bit 0

//the seven segment displays will show distance covered in the form of 0W_F
// where W is the whole number of miles and F is the fractional number of miles								
assign distance_covered_bcd3 = (shift_register[31:1]/10) % 10;
assign distance_covered_bcd2 = shift_register[31:1] % 10; //whole number of miles
assign distance_covered_bcd1 = 5'h1F; //displays a "_"
assign distance_covered_bcd0 = (shift_register[0] == 1'b1) ? 5'd5 : 5'd0;



/**********Part 3: Steps Over 32/sec ***********/


/* attempt 1
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

assign steps_over_32_bcd0 = steps_over_32_per_sec_counter % 10; 
assign steps_over_32_bcd1 = (steps_over_32_per_sec_counter/10) % 10;
assign steps_over_32_bcd2 = (steps_over_32_per_sec_counter/100) % 10;
assign steps_over_32_bcd3 = (steps_over_32_per_sec_counter/1000) % 10;
*/
/*
//attempt 2
reg [30:0] steps_in_prev_sec;
reg [30:0] second_counter;
reg [30:0] num_steps_over_32_per_sec;
wire [30:0] num_steps_in;

always @(posedge step_clk or posedge reset or posedge one_Hz_clk_SP)  //steps in one sec counter
begin
	if(reset == 1'b1) steps_in_one_sec_counter <= 31'b0;
	else if(one_Hz_clk_SP) steps_in_one_sec_counter <= 31'b0;
	else steps_in_one_sec_counter <= steps_in_one_sec_counter + 1;
end

always @(posedge one_Hz_clk_SP or posedge reset)
begin
	if(reset == 1'b1) steps_in_prev_sec <= 31'b0;
	else steps_in_prev_sec <= steps_in_one_sec_counter;
end

always @(posedge one_Hz_clk_SP or posedge reset)
begin
	if(reset == 1'b1) second_counter <= 31'b0;
	else second_counter <= second_counter + 1;
end

always @(posedge one_Hz_clk_SP or posedge reset)
begin
	if(reset == 1'b1)  num_steps_over_32_per_sec <= 31'b0;
	else num_steps_over_32_per_sec <= num_steps_in;
end

assign num_steps_in = ((steps_in_prev_sec > 32) && (second_counter < 9)) + num_steps_over_32_per_sec;

assign steps_over_32_bcd0 = num_steps_over_32_per_sec % 10; 
assign steps_over_32_bcd1 = (num_steps_over_32_per_sec/10) % 10;
assign steps_over_32_bcd2 = (num_steps_over_32_per_sec/100) % 10;
assign steps_over_32_bcd3 = (num_steps_over_32_per_sec/1000) % 10;
*/


//attempt 3
wire step_clk_SP;
reg [30:0] num_steps_over_32_per_sec;
single_pulse step_single_pulser(sys_clk, step_clk, step_clk_SP); //synchronizes the step pulses with the system clk
single_pulse single_pulser(sys_clk, one_Hz_clk, one_Hz_clk_SP); // sys clk length pulse generated for 1 hz clk posedge 
always @(posedge sys_clk)
begin
	if(reset) begin
		second_counter <= 31'b0;
		num_steps_over_32_per_sec <= 31'b0;
		steps_in_one_sec_counter <= 31'b0;
	end
	
	else if(one_Hz_clk_SP) begin //every second, do the following
		if((steps_in_one_sec_counter > 32) && second_counter < 9) begin
			second_counter <= second_counter + 1;
			num_steps_over_32_per_sec <= num_steps_over_32_per_sec + 1;
			steps_in_one_sec_counter <= 31'b0;
		end 
		else if(second_counter < 9) begin
			second_counter <= second_counter + 1;
			steps_in_one_sec_counter <= 31'b0;
		end
		else steps_in_one_sec_counter <= 31'b0;
	end
	
	else if(step_clk_SP) begin
		steps_in_one_sec_counter <= steps_in_one_sec_counter + 1;
	end

end

assign steps_over_32_bcd0 = num_steps_over_32_per_sec % 10; 
assign steps_over_32_bcd1 = (num_steps_over_32_per_sec/10) % 10;
assign steps_over_32_bcd2 = (num_steps_over_32_per_sec/100) % 10;
assign steps_over_32_bcd3 = (num_steps_over_32_per_sec/1000) % 10;
		
			
			


/*****************Part 4: High Activity Time Greater than Threshold************/
always @(posedge one_Hz_clk_SP or posedge reset) 
begin
	if(reset == 1'b1) cont_sec_of_high_activity <= 31'b0;
	else cont_sec_of_high_activity <= cont_sec_in;
end

always @(posedge one_Hz_clk_SP or posedge reset)
begin
	if(reset == 1'b1) display_reg <= 31'b0;
	else display_reg <= display_reg_in;
end


assign cont_sec_sel = (steps_in_one_sec_counter >= 64) ? 1'b1 : 1'b0;
assign cont_sec_in = cont_sec_sel ? (cont_sec_of_high_activity + 1) : 31'b0;
assign equals_60_sel = (cont_sec_of_high_activity == 60) ? 1'b1 : 1'b0;
assign greater_than_60_sel = (cont_sec_of_high_activity > 60) ? 1'b1 : 1'b0;
assign display_reg_in = greater_than_60_sel ? (display_reg + 1) : (equals_60_sel ? (display_reg + 60) : display_reg);

assign high_activity_bcd0 =  display_reg % 10;
assign high_activity_bcd1 = (display_reg/10) % 10;
assign high_activity_bcd2 = (display_reg/100) % 10;
assign high_activity_bcd3 = (display_reg/1000) % 10;



/**************Display Changer************/
always @(posedge half_Hz_clk or posedge reset)
begin
	if(reset) state <= 2'b00;
	else state <= next_state;
end

always @(*)
begin

			bcd3 = steps_over_32_bcd3;
			bcd2 = steps_over_32_bcd2;
			bcd1 = steps_over_32_bcd1;
			bcd0 = steps_over_32_bcd0;
/*	case(state) 
		2'b00: begin
			bcd3 = step_counter_bcd3;
			bcd2 = step_counter_bcd2;
			bcd1 = step_counter_bcd1;
			bcd0 = step_counter_bcd0;
			next_state = 2'b01;
		end
		2'b01: begin
			bcd3 = distance_covered_bcd3;
			bcd2 = distance_covered_bcd2;
			bcd1 = distance_covered_bcd1;
			bcd0 = distance_covered_bcd0;
			next_state = 2'b10;
		end
		2'b10: begin
			bcd3 = steps_over_32_bcd3;
			bcd2 = steps_over_32_bcd2;
			bcd1 = steps_over_32_bcd1;
			bcd0 = steps_over_32_bcd0;
			next_state = 2'b11;
		end
		2'b11: begin
			bcd3 = high_activity_bcd3;
			bcd2 = high_activity_bcd2;
			bcd1 = high_activity_bcd1;
			bcd0 = high_activity_bcd0;
			next_state = 2'b00;
		end
	endcase */
end
			
endmodule



/************Single Pulse*****************/
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