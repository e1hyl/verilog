module i2c_clk_divider(
    input  logic reset,
    input  logic ref_clk,
    output logic i2c_clk
);


// converting 100MHz divided by 1000 to get us to 100KHz

parameter DELAY = 1000;

logic [9:0] count = 0;


initial i2c_clk = 0;


always @(posedge ref_clk) begin
    if(reset == 1) begin
        i2c_clk = 0;
        count = 0;
    end
    else begin
        if(count == ((DELAY/2) - 1)) begin
            i2c_clk = ~i2c_clk;
            count = 0;
        end
        else begin
            count = count + 1;
        end
    
    end

end

endmodule