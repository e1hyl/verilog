

module i2c_main(
  input logic   clk,
  input logic   reset,
  
  input logic   start,
  input logic   [6:0] addr,
  input logic   [7:0] data,
  output logic  i2c_sda,
  output logic  i2c_scl,
  output logic  ready
);

  localparam STATE_IDLE  = 0;
  localparam STATE_START = 1;
  localparam STATE_ADDR  = 2;
  localparam STATE_RW    = 3;
  localparam STATE_WACK  = 4;
  localparam STATE_DATA  = 5;
  localparam STATE_STOP  = 6;
  localparam STATE_WACK2 = 7;
  
  // goal: write to device address 50H, AAH
  
  logic [7:0] state;
  logic [7:0] count;
  logic i2c_scl_enable = 0;  

  
  logic [6:0] saved_addr;
  logic [7:0] saved_data;


  assign i2c_scl = (i2c_scl_enable == 0) ? 1 : ~clk;
  assign ready = ((reset == 0) && (state == STATE_IDLE)) ? 1 : 0;

  always @(negedge clk) begin
    if(reset == 1) begin
        i2c_scl <= 0;
    end 
    else begin
        if ((state == STATE_IDLE) || (state == STATE_START) || (state == STATE_STOP)) begin
            i2c_scl_enable <= 0;    
        end
        else begin
            i2c_scl_enable <= 1; // toggle
        end
    end
  end

  
  always @(negedge clk) begin
    
    if(reset == 1) begin
    	state   <= STATE_IDLE;
      	i2c_sda <= 1;
      	count   <= 8'd0;
    end
    
    else begin
      case(state)
        
        STATE_IDLE: begin 
          	i2c_sda <= 1;
          	
            if(start) begin
              state <= STATE_START;
              saved_addr <= addr;
              saved_data <= data;
            end
			
            else state <= STATE_IDLE;
           
        end
        
        STATE_START: begin 
          	i2c_sda <= 0;
          	state <= STATE_ADDR;
          	count <= 6;
        end
        
        STATE_ADDR: begin // 
          	i2c_sda <= saved_addr[count];
          	if (count == 0) state <= STATE_RW;
          	else count <= count - 1;
        end
        
        STATE_RW: begin
          	i2c_sda <= 1;
          	state   <= STATE_WACK;
        end  
        
        STATE_WACK: begin
          	state <= STATE_DATA;
        end

        STATE_DATA: begin
            i2c_sda <= saved_data[count];
            if (count == 0) state <= STATE_WACK2;
            else count <= count - 1;
        end
    
        STATE_WACK2: begin
            state <= STATE_STOP;
        end
          	
        STATE_STOP: begin
            i2c_sda <= 1;
            state <= STATE_IDLE;
        end
        
      endcase
    
    end
  
  end
endmodule