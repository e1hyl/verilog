
module uart_tb();

// input(s)
reg rst;


// output(s)
reg [7:0] transmit_dataA;
reg [7:0] transmit_dataB;
reg [7:0]  receive_dataA;
reg [7:0]  receive_dataB;

top_uart uut(
  	.rst(rst),
    .transmit_dataA(transmit_dataA),
    .transmit_dataB(transmit_dataB),
    .receive_dataA(receive_dataA),
    .receive_dataB(receive_dataB)
);


initial begin

    rst = 1;

    #5

    rst = 0;

    #5

    $dumpfile("dump.vcd");
    $dumpvars;

    #2000
    $finish;

end


endmodule