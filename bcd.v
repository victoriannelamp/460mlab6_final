module seven_seg_display( input clk,
 input [4:0] bcd0, bcd1, bcd2, bcd3,  //the 4 inputs for each display
 output a, b, c, d, e, f, g, dp, //segments 
 output [3:0] an   // the 4 bit enable signal
 );
 
 
localparam N = 17; //18 but changed to test simulation 
 
reg [N-1:0]count; //the 18 bit counter which allows us to multiplex at 1000Hz
reg [4:0]sseg; //the register to hold the data to output
reg [3:0]an_temp; //register for the 4 bit enable
reg [7:1] sseg_temp; // 7 bit register to hold the binary value of each input given


initial 
begin 
count <= 0; 
end 

 
always @ (posedge clk)
begin
   count <= count + 1;
end
 
 
always @ (*)
 begin
  case(count[N-1:N-2]) //using only the 2 MSB's of the counter 
    
   2'b00 :  //When the 2 MSB's are 00 enable the fourth display
    begin
     sseg = bcd0;
     an_temp = 4'b1110;
    end
    
   2'b01:  //When the 2 MSB's are 01 enable the third display
    begin
     sseg = bcd1;
     an_temp = 4'b1101;
    end
   2'b10:  //When the 2 MSB's are 10 enable the second display
    begin
     sseg = bcd2;
     an_temp = 4'b1011;
    end
     
   2'b11:  //When the 2 MSB's are 11 enable the first display
    begin
     sseg = bcd3;
     an_temp = 4'b0111;
    end
  endcase
 end
 
assign an = an_temp;
 
 
always @ (*)
 begin
  case(sseg)
   5'd0 : sseg_temp = 7'b1000000; //to display 0
   5'd1 : sseg_temp = 7'b1111001; //to display 1
   5'd2 : sseg_temp = 7'b0100100; //to display 2
   5'd3 : sseg_temp = 7'b0110000; //to display 3
   5'd4 : sseg_temp = 7'b0011001; //to display 4
   5'd5 : sseg_temp = 7'b0010010; //to display 5
   5'd6 : sseg_temp = 7'b0000010; //to display 6
   5'd7 : sseg_temp = 7'b1111000; //to display 7
   5'd8 : sseg_temp = 7'b0000000; //to display 8
   5'd9 : sseg_temp = 7'b0010000; //to display 9
   5'h0A : sseg_temp = 7'b0001000; //to display A
   5'h0B : sseg_temp = 7'b0000011; //to display b
   5'h0C : sseg_temp = 7'b1000110; //to display C
   5'h0D : sseg_temp = 7'b0100001; //to display d
   5'h0E : sseg_temp = 7'b0000110; //to display E
   5'h0F : sseg_temp = 7'b0001110; //to display F
   5'h1F : sseg_temp = 7'b1110111; //to display _
   default : sseg_temp = 7'b1111111; //none
  endcase
 end
 
assign {g, f, e, d, c, b, a} = sseg_temp; //concatenate the outputs to the register
assign dp = 1'b1; //turn off decimal point 
 
 
endmodule

