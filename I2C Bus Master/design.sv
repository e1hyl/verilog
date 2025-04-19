module i2c_main(
  input logic   clk,
  input logic   reset, 
  output logic  i2c_sda,
  output logic  i2c_scl
);

  
  typedef enum logic [2:0] {STATE_IDLE, STATE_START, STATE_ADDR, STATE_RW, STATE_WACK, STATE_DATA, STATE_STOP, STATE_WACK2} State;

  State currentState, nextState;


  logic [7:0] count_next;
  logic i2c_sda_next;
  logic [7:0] count;
  logic [6:0] addr;
  logic [7:0] data;
  
  logic i2c_scl_enable = 0;  


  assign i2c_scl = (i2c_scl_enable == 0) ? 1 : ~clk;
  
  always @(negedge clk) begin
    if(reset == 1) begin
        i2c_scl_enable <= 0;
    end 
    else begin
        if ((currentState == STATE_IDLE) || (currentState == STATE_START) || (currentState == STATE_STOP)) begin
            i2c_scl_enable <= 0;    
        end
        else begin
            i2c_scl_enable <= 1; // toggle
        end
    end
  end

  
  always_ff @(posedge clk) 
    
    if(reset == 1) begin
      currentState <= STATE_IDLE;
      i2c_sda <= 0;
      addr <= 7'h50;
      count <= 8'd0;
      data <= 8'haa;
    end
    else begin
      i2c_sda <= i2c_sda_next;
      count <= count_next;
      currentState <= nextState;
    end
    
    always_comb
      
      case(currentState)
        
        STATE_IDLE: begin
          	i2c_sda_next = 1;
            nextState = STATE_START;
        end
        
        STATE_START: begin 
          	i2c_sda_next = 0;
          	nextState = STATE_ADDR;
          	count_next = 6;
        end
        
        STATE_ADDR: begin 
          	i2c_sda_next = addr[count_next];
          	if (count_next == 0) nextState = STATE_RW;
          	else count_next = count_next - 1;
        end
        
        STATE_RW: begin
          	i2c_sda_next = 1;
          	nextState   = STATE_WACK;
        end  
        
        STATE_WACK: begin
          	nextState = STATE_DATA;
        end

        STATE_DATA: begin
            i2c_sda_next = data[count];
            if (count_next == 0) nextState = STATE_WACK2;
            else count_next = count_next - 1;
        end
    
        STATE_WACK2: begin
            nextState = STATE_STOP;
        end
          	
        STATE_STOP: begin
            i2c_sda_next = 1;
            nextState = STATE_IDLE;
        end
        
      endcase
    
    
  
  
endmodule


module i2c_clk_divider #(parameter DELAY = 1000)
(
    input  logic reset,
    input  logic ref_clk,
    output logic i2c_clk
);


// converting 100MHz divided by 1000 to get us to 100KHz

logic [9:0] count = 0;


initial i2c_clk = 0;


always @(posedge ref_clk) begin
        if(count == ((DELAY/2) - 1)) begin
            i2c_clk = ~i2c_clk;
            count = 0;
        end
        else begin
            count = count + 1;
        end
        
end

endmodule
