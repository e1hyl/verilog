`timescale 1ns / 1ps

module i2c_tb();
  
  reg clk;
  reg reset;
  
  // outputs
  wire i2c_sda;
  wire i2c_scl;


  i2c_clk_divider #(.DELAY(1000)) instance(
    .reset(reset),
    .ref_clk(clk),
    .i2c_scl(i2c_scl)
  );
  

  i2c_main uut1(
    .clk(clk),
    .reset(reset),
    .i2c_sda(i2c_sda),
    .i2c_scl(i2c_scl)
  );


  initial begin
    clk = 0;
    forever begin
      clk = #5 ~clk;
    end
  end
  
  initial begin
  	
    reset = 1;
    
    $dumpfile("i2c_tb.vcd");
    $dumpvars(0, i2c_tb);

    #10000;
    
    reset = 0;

    #160000;

    $finish;
  
  end
  
endmodule
  