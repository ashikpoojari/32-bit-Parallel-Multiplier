`timescale 1ns/1ps
`include "Proc_32.v"
`include "PrAcc.v"

module test_mult35x35_parallel_pipe;

parameter CLK_PERIOD = 2;


reg           CLK, RST, RSTP;
reg   [34:0]  A_IN;
reg   [34:0]  B_IN;
wire  [69:0]  PROD_OUT;
wire  [48:0]  ACCUM48_OUT;



mult35x35_parallel_pipe test(.CLK(CLK), .RST(RST), .A_IN(A_IN), .B_IN(B_IN), .PROD_OUT(PROD_OUT));
accum48 test1(.CLK(CLK), .RST(RST), .RSTP(RSTP), .A_IN(PROD_OUT[63:32]), .ACCUM48_OUT(ACCUM48_OUT));



initial
begin
CLK <= 1'b0;
RST <= 1'b1;
RSTP <= 1'b1;
#20 RST <= 1'b0; RSTP <= 1'b0;
end

initial
begin
$dumpfile("mul32.vcd");
$dumpvars(0, test_mult35x35_parallel_pipe);

end


always
#(CLK_PERIOD/2) CLK = ~CLK;

initial
begin

#30 A_IN <= 35'd34359738367;
/*#65 A_IN <= 35'd1048575;//65537;//1048575;
#65 A_IN <= 35'd10;
#65 A_IN <= 35'd1115;
#65 A_IN <= 35'd17179869183;*/
end

initial
begin

#30 B_IN <= 35'd7835;
//#100 B_IN <= 35'd34359738367;//2020;
/*#65 B_IN <= 35'd1048575;
#65 B_IN <= 35'd1115;
#65 B_IN <= 35'd17179869183;*/
#1000 $finish;
end




initial

$monitor ($time, "clk=%b", CLK, " PROD_OUT = %h", PROD_OUT);
endmodule
