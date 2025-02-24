module top(
  input clk, rst,
  output [31:0] Alu_result,
  output [31:0] Immediate_result,
  output [31:0] PC,
  output [31:0] Instruction,
  output [4:0] rs1,
  output [4:0] rs2,
  output [31:0] Data1,
  output [31:0] Data2,
  output [31:0] DataW,
  output [31:0] DataMem_Out 
);

  wire [31:0] pc_4, pc_o, pc_i;
  wire [31:0] ins_out;

  wire [6:0] opcode, Funct7;
  wire [4:0] Rs1, Rs2, Rd;
  wire [2:0] Funct3;
  wire [11:0] imm;

  wire [1:0] WBSel, ALUSel; // control signal wires
  wire regWrite, BSel, MEMRW, PcToAlu, PcALuMem; 

  wire [31:0] imm_out; // imm from immediate generator
  wire [31:0] alu_out, dataMem_out; 
  wire [31:0] dataW;
  wire [31:0] data1, data2;

  wire [31:0] mux_2x1_out1, mux_2x1_out2; // data1 or pc_o, data2 or imm_out
 
  
  mux_2x1 m2(alu_out, pc_4, PcALuMem, pc_i);
  program_coutner p0(clk, rst, pc_i, pc_o);
  adder a0(pc_o, 32'd4, pc_4);
  instruction_memory i0(pc_o, rst, ins_out); // got the instruction

  decoder d0(ins_out, opcode, Rd, Funct3, Rs1, Rs2, Funct7, imm);
  control_unit c0(ins_out, regWrite, BSel, MEMRW, PcToAlu, PcALuMem, WBSel, ALUSel);

  regfile r0(clk, regWrite, Rs1, Rs2, Rd, dataW, data1, data2);
  mux_2x1 m1(pc_o, data1, PcToAlu, mux_2x1_out1);

  imm_gen im0(ins_out, imm_out);
  mux_2x1 m0(imm_out, data2, BSel, mux_2x1_out2);

  alu al0(aluSel, mux_2x1_out1, mux_2x1_out2, alu_out);
  data_memory dm0(alu_out, MEMRW, dataMem_out);  
  
  mux_3x1 m3(dataMem_out, alu_out, pc_4, PcALuMem, dataW);

  //mux_2x1 m1(alu_out, dataMem_out, Bsel, dataW); // need to change to 3x1 mux_2x1

  assign DataW = dataW;
  assign DataMem_Out = dataMem_out;
  assign Alu_result = alu_out;
  assign Immediate_result = imm_out;
  assign PC = pc_4;
  assign Instruction = ins_out;
  assign rs1 = Rs1;
  assign rs2 = Rs2;
  assign Data1 = data1;
  assign Data2 = data2;

endmodule


module control_unit (
  input [31:0] instruction,
  output reg RegWrite, BSel, MEMRW, PcToAlu, PcALuMem,
  output reg [1:0] WBSel, // Write Back Select 
  output reg [1:0] ALUSel 
);
  
  wire [6:0] opcode = instruction [6:0];
  wire [2:0] funct3 = instruction [14:12];
  wire [6:0] funct7 = instruction [31:25];

  always @(*) begin
    casez ({opcode, funct3, funct7})
     
      17'b0110011_000_0000000: begin  // add
        RegWrite = 1;
        BSel = 0;
        ALUSel = 2'b00;
        WBSel = 2'b01;
        MEMRW = 1'bx;
        PcToAlu = 0;
        PcALuMem = 0;
      end
      
      17'b0010011_000_???????: begin  // addi
        RegWrite = 1;
        BSel = 1;
        ALUSel = 2'b00;
        WBSel = 2'b01;
        MEMRW = 1'bx;
        PcToAlu = 0;
        PcALuMem = 0;
      end
      
      17'b0000011_010_???????: begin  // lw 
        RegWrite = 1;
        BSel = 1;
        ALUSel = 2'b00;
        WBSel = 2'b00;
        MEMRW = 0;
        PcToAlu = 0;
        PcALuMem = 0;
      end
      
      17'b0100011_010_???????: begin  // sw 
        RegWrite = 0;
        BSel = 1;
        ALUSel = 2'b00;
        WBSel = 2'bx;
        MEMRW = 1;
        PcToAlu = 0;
        PcALuMem = 0;
      end
        
      17'b110111_???_???????: begin  // jal 
        RegWrite = 0;
        BSel = 1;
        ALUSel = 2'b00;
        WBSel = 2'b10;
        MEMRW = 1;
        PcToAlu = 1;
        PcALuMem = 1;
      end

      default: begin
        RegWrite = 0;
        BSel = 0;
        ALUSel = 2'b00;
        BSel = 1'bx;
        MEMRW = 1'bx;
        PcToAlu = 0;
      end
  
    endcase
  end

endmodule

module program_coutner (
  input clk, rst,   
  input [31:0] pc_in,
  output reg [31:0] pc_out 
);

  always @(posedge clk) begin
    if(rst) begin
      pc_out <= 32'b0;
    end else begin
      pc_out <= pc_in;
    end
  end

endmodule

module adder(
  input [31:0] a, b,
  output [31:0] sum
);
  
  assign sum = a + b;

endmodule

module instruction_memory (
  input [31:0] address,
  input rst,
  output [31:0] instruction
);
  
  reg [7:0] inst_mem [1023:0];
  
  assign instruction = {inst_mem[address+3], inst_mem[address+2], inst_mem[address+1], inst_mem[address]};
  
  always @(rst) begin
    if(rst == 1) begin
    
    // add x3 x2 x1
    inst_mem[3] = 8'h00;
    inst_mem[2] = 8'h11;
    inst_mem[1] = 8'h01;
    inst_mem[0] = 8'hb3;
    
    // addi x4 x2 25
    inst_mem[7] = 8'h83;
    inst_mem[6] = 8'h40;
    inst_mem[5] = 8'h82;
    inst_mem[4] = 8'h13;
    
    // sw x1 1000(x2)
    inst_mem[15] = 8'h3e;
    inst_mem[14] = 8'h11;
    inst_mem[13] = 8'h24;
    inst_mem[12] = 8'h23;

    // lw x10 1000(x2)
    inst_mem[11] = 8'h3e;
    inst_mem[10] = 8'h81;
    inst_mem[9] = 8'h25;
    inst_mem[8] = 8'h03;

    end

  end


endmodule

module imm_gen (
  input [31:0] instruction,
  output reg [31:0] immediate
);
  
  parameter i_opcode1 = 7'b0010011; // addi etc.
  parameter i_opcode2 = 7'b0000011; // lw etc.
  parameter s_opcode1 = 7'b0100011; // sw etc.
  parameter j_opcode1 = 7'b1101111; // jal 

  wire [6:0] opcode = instruction [6:0];

  wire [11:0] immediate_i = instruction[31:20];
  wire [11:0] immediate_s = {instruction[31:25], instruction[11:7]};
  wire [11:0] immediate_j = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};

  always @(*) begin
    case(opcode) 
      i_opcode1, i_opcode2: immediate = {{20{instruction[31]}}, immediate_i};
			s_opcode1: immediate = { {20{instruction[31]}} , immediate_s};
      j_opcode1: immediate = { {20{instruction[31]}}, immediate_j}
      default: immediate = 32'bx;
    endcase
  end
  
endmodule

module decoder (
  input [31:0] instruction,
  output  [6:0] OPCODE,
  output reg [4:0] rd,
  output reg [2:0] funct3,
  output reg [4:0] rs1, rs2,
  output reg [6:0] funct7,
  output reg [11:0] immediate
);
  
  wire [6:0] opcode = instruction; 

  parameter arithmetic_r = 7'b0110011;
  parameter arithmetic_i1 = 7'b0010011;
  parameter loads = 7'b0000011;
  parameter stores = 7'b0100011; 

  always @(*) begin
    case(opcode)

      arithmetic_r: begin
        rd = instruction[12:7];
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        funct7 = instruction[31:25];
        immediate = 12'bx;
      end

      arithmetic_i1, loads: begin
        rd = instruction[11:7];
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = 5'bx;
        immediate = instruction[31:20];
        funct7 = 7'bx;
      end
  
      stores: begin
        rd = 5'bx;
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        immediate = {instruction[31:25], instruction[11:7]};
        funct7 = 7'bx;
      end

      default: begin
        rd = 5'b0; 
        funct3 = 3'b0;
        rs1 = 5'b0;
        rs2 = 5'b0;
        funct7 = 7'b0;
        immediate = 12'b0;
      end
    
    endcase
  end

  assign OPCODE = instruction [6:0]; 


endmodule

module regfile (
  input clk, RegWrite,
  input [4:0] rs1, rs2, rd,
  input [31:0] WriteData,
  output [31:0] ReadData1, ReadData2
);
  reg [31:0] Reg [31:0];
  
  initial begin
    Reg[1]=5;
    Reg[2]=6;
    Reg[3]=7;
    Reg[4]=2;	
    Reg[5]=3;
    Reg[6]=1;	
    Reg[7]=0;
    Reg[8]=9;
    Reg[9]=23;
    Reg[10]=11;
  
    Reg[11]=5;
    Reg[12]=6;
    Reg[13]=7;
    Reg[14]=2;	
    Reg[15]=3;
    Reg[16]=1;	
    Reg[17]=0;
    Reg[18]=32;
    Reg[19]=15;
    Reg[20]=11;
    
    Reg[21]=5;
    Reg[22]=6;
    Reg[23]=7;
    Reg[24]=2;	
    Reg[25]=3;
    Reg[26]=1;	
    Reg[27]=0;
    Reg[28]=28;
    Reg[29]=6;
    Reg[30]=17;
    Reg[31]=31;
  end

  always @(posedge clk) begin
    Reg[0] = 0;
    
    if(RegWrite) begin
      Reg[rd] = WriteData;
    end

  end

  assign ReadData1 = Reg[rs1]; 
  assign ReadData2 = Reg[rs2];

endmodule

module mux_2x1 (
  input [31:0] a, b, 
  input s,
  output [31:0] y
);

  assign y = s ? a : b;

endmodule

module mux_3x1 (
  input [31:0] a, b, c,
  input [1:0] s,
  output [31:0] y
);
  
  always @(*) begin
    case(s) 
      2'b00: y = a;
      2'b01: y = b;
      2'b10: y = c;
      default: y = 32'b0;  
    endcase
  end

endmodule

module alu (
  input [1:0] ALUSel,
  input [31:0] data1, data2,
  output reg [31:0] result
);

  always @(*) begin
    case(ALUSel) 
      2'b00: result = data1 + data2;
      2'b10: result = data1 || data2;
      default: result = 32'b0; 
    endcase
  end

endmodule

module data_memory(
  input [31:0] addr,
  input MEMRW, 
  output reg [31:0] dataR
);

  reg [7:0] data_mem [1023:0];
  
  integer i;

  initial begin
    for (i = 0; i < 1024; i = i + 1) begin  
      data_mem[i] = i;
    end
  end

  always @(*) begin
    if(MEMRW)
    begin
      dataR[7:0] = data_mem[addr];    
      dataR[15:8] = data_mem[addr+1];    
      dataR[23:16] = data_mem[addr+2];    
      dataR[31:24] = data_mem[addr+3];    
    end
    
    else begin
      data_mem[addr] = dataR[7:0];
      data_mem[addr+1] = dataR[15:8];
      data_mem[addr+2] = dataR[23:16];
      data_mem[addr+3] = dataR[31:24];
    end

  end 

endmodule


