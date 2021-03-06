module tracker_tb();

reg step_clk, one_Hz_clk, sys_clk, reset;
wire si, bcd3, bcd2, bcd1, bcd0;

initial begin
sys_clk = 1'b0;
forever #1 sys_clk = ~sys_clk;
end

initial begin
step_clk = 1'b0;
forever #5 step_clk = ~step_clk;
end

initial begin
one_Hz_clk = 1'b0;
forever #200 one_Hz_clk = ~one_Hz_clk;
end

initial begin
reset = 1;
#30
reset = 0;
#40000
$finish;
end

tracker tracker_module(step_clk, reset, one_Hz_clk, sys_clk, si, bcd3, bcd2, bcd1, bcd0);

endmodule