`timescale 1ns / 1ps


module proc_tb();

  reg clk, rst;
  wire [31:0] Alu_result;
  wire [31:0] Immediate_result;
  wire [31:0] PC;
  wire [31:0] Instruction;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [31:0] Data1;
  wire [31:0] Data2;
  

  top dut(
    .clk(clk),
    .rst(rst),
    .Alu_result(Alu_result),
    .Immediate_result(Immediate_result),
    .PC(PC),
    .Instruction(Instruction),
    .rs1(rs1),
    .rs2(rs2),
    .Data1(Data1),
    .Data2(Data2)
  );

  initial begin
    forever #30 clk = ~clk;
  end

  initial begin
    clk = 1;

    $dumpfile("proc_tb.vcd");
    $dumpvars(0, proc_tb);

    
    rst = 1;

    #20 rst = 0;
    
    #1000 $finish;


  end

endmodule
