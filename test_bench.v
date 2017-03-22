`timescale 1ns / 100ps
`include "Proc_32.v"

module testbench;

localparam W=35;
reg clk_tb,rst_tb;
integer i=0,j=0;

reg [W-1:0] a_tb,b_tb;

reg flag;
wire [2*W-1:0] product_tb;
reg [2*W-1:0] k;
//test_tb;

mult35x35_parallel_pipe test (.A_IN(a_tb), .B_IN(b_tb), .CLK(clk_tb), .RST(rst_tb), .PROD_OUT(product_tb));

always @ (*) begin
	#5 clk_tb <= ~ clk_tb;
	end

initial
begin
	$dumpfile("mul32.vcd");
	$dumpvars(0, testbench);
clk_tb=1; rst_tb=1;i=0;j=0;flag=0;
#20 rst_tb=0;


//#10 rst_tb=0;a_tb= 777216;b_tb=345256;
//#10 a_tb=64; b_tb=64;
//#10 ready_tb=0;a_tb= 16777215;b_tb=16777215; k=a_tb*b_tb;
////#10 a_tb= 7349004;b_tb=4904782;
//#100
//$display ($time," product= %d expected product=%d", product_tb,k);

for (i=34359738369;i<34359738370;i=i+1)begin
	for (j=34359738369;j<34359738370;j=j+1) begin
		a_tb=i;b_tb=j;k=a_tb*b_tb;
		#170 if(product_tb != k) begin
				$monitor($time,"ERROR 101");
				flag=1;
			end
			//else
			//$display ($time," product= %d expected product=%d ", product_tb,k);
	end
end

if (flag==1)
	$display($time,"Test failed??");
else
	$display($time,"Test successfull!!");

$finish;
end



endmodule
