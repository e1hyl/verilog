module top_uart(    
    input rst,

    output [7:0] transmit_dataA,
    output [7:0] transmit_dataB,
    output [7:0]  receive_dataA,
    output [7:0]  receive_dataB
);
    wire start_a, start_b;
    wire stop_a, stop_b;

    wire [7:0] trx_a, trx_b;

  	devA d0(.rst(rst), .start(start_a), .stop(stop_a), .rx(trx_b), .tx(trx_a));
    devB d1(.rst(rst), .start(start_b), .stop(stop_b), .rx(trx_a), .tx(trx_b));
    

    assign transmit_dataA = trx_a;
    assign transmit_dataB = trx_b;
  
    assign receive_dataA  = trx_b;
    assign receive_dataB  = trx_a;

endmodule

module devA(
  input wire rst,
  
  input wire start, 
  input wire stop,
  
  input wire [7:0] rx,
  output reg [7:0] tx
  
);
  
  localparam STATE_IDLE  = 0;
  localparam STATE_START = 1;
  localparam STATE_DATA  = 2;
  localparam STATE_STOP  = 3;
  
  reg [1:0] state;
  reg [7:0] data_out;
  reg [7:0] count;
  
  always @(*) begin
    if(rst) begin
    	state    = STATE_IDLE;
        count    = 7;
        data_out = 8'hFF;
        tx       = 8'h4D; 
    end
    
    else begin
      case(state)
        
        STATE_IDLE: begin
          
          if(start) begin
          	state = STATE_START;
          end
          else state = STATE_IDLE;
        
        end
        
        STATE_START: state = STATE_DATA;
        
        STATE_DATA: begin
            if(count > 0) begin   
                state = STATE_DATA;  
                data_out[count] = tx[count];
                count = count - 1;
            end
            else state = STATE_STOP;
        end

        STATE_STOP: begin
            if(stop) state = STATE_IDLE;
            else state = STATE_STOP;
        end
        
      endcase
    end

  end

endmodule

module devB(
  input wire rst,
  
  input wire start,
  input wire stop,
  
  input wire [7:0] rx,
  output reg [7:0] tx
  
);
  
  localparam STATE_IDLE  = 0;
  localparam STATE_START = 1;
  localparam STATE_DATA  = 2;
  localparam STATE_STOP  = 3;
  
  reg state;
  reg [7:0] data_out;
  reg [7:0] count;
  
  always @(*) begin
    if(rst) begin
    	state    = STATE_IDLE;
        count    = 7;
        data_out = 8'hFF;
        tx       = 8'h5A;
    end
    
    else begin
      case(state)
        
        STATE_IDLE: begin
          data_out = 8'hFF;
          if(start) begin
          	state = STATE_START;
          end
          else state = STATE_IDLE;
        
        end
        
        STATE_START: state = STATE_DATA;
        
        STATE_DATA: begin
            if(count > 0) begin   
                state = STATE_DATA;  
                data_out[count] = tx[count];
                count = count - 1;
            end
            else state = STATE_STOP;
        end

        STATE_STOP: begin
            if(stop) state = STATE_IDLE;
            else state = STATE_STOP;
        end
        
      endcase
    end

  end

endmodule

