`timescale 1ns / 1ps

module i2c_tb();
  
  reg clk;
  reg reset;
  
  // outputs
  wire i2c_sda;
  wire i2c_scl;


  i2c_main uut1(
    .clk(clk),
    .reset(reset),
    .i2c_sda(i2c_sda),
    .i2c_scl(i2c_scl)
  );


  i2c_clk_divider uut2(
    .reset(reset),
    .ref_clk(clk),
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
 
    #10000;
    
    reset = 0;

  #160000;

    $finish;
  
  end
  
endmodule
  