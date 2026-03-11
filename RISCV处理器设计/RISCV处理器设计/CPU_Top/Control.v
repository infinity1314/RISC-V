`timescale 1ns / 1ps

module Control(
    input [6:0]  opcode,
    output reg [0:0] Branch,
    output reg [0:0] MemRead,
    output reg [0:0] MemtoReg,
    output reg [2:0] ALUOp,
    output reg [0:0] MemWrite,
    output reg [0:0] ALUSrc,
    output reg [0:0] RegWrite,
	output reg  jal_select
    );
always @ (*)  begin
    case(opcode)
    //add sub sll slt sltu xor srl sra or and
    7'b0110011:begin
        Branch      = 1'b0;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b0;
        ALUOp       = 3'b010;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b0;
        RegWrite    = 1'b1;
		jal_select  = 1'b0;
     end
    //addi slti sltiu xori ori andi slli srli srai
    7'b0010011:begin
        Branch      = 1'b0;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b0;
        ALUOp       = 3'b011;//////////////////////
        MemWrite    = 1'b0;
        ALUSrc      = 1'b1;
        RegWrite    = 1'b1;
		jal_select  = 1'b0;
     end
    //beq bne blt bge bltu bgeu
    7'b1100011:begin
        Branch      = 1'b1;  
        MemRead     = 1'b0;//x
        MemtoReg    = 1'b0;//x
        ALUOp       = 3'b001;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b0;
        RegWrite    = 1'b0;
		jal_select  = 1'b0;
     end
    //sb sh sw
    7'b0100011:begin
        Branch      = 1'b0;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b0;//x
        ALUOp       = 3'b001;
        MemWrite    = 1'b1;
        ALUSrc      = 1'b1;
        RegWrite    = 1'b0;
		jal_select  = 1'b0;
     end
    //lb lh lw lbu lhu
    7'b0000011:begin
        Branch      = 1'b0;  
        MemRead     = 1'b1;
        MemtoReg    = 1'b1;
        ALUOp       = 3'b100;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b1;
        RegWrite    = 1'b1;
		jal_select  = 1'b0;
     end     
    //luI		??
    7'b0110111:begin
        Branch      = 1'b1;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b1;
        ALUOp       = 3'b101;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b1;
        RegWrite    = 1'b1;
		jal_select  = 1'b0;
     end

    //auipc   ???
   /*  7'b0010111:begin
        Branch      = 1'b1;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b1;
        ALUOp       = 2'b11;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b1;
        RegWrite    = 1'b1;
     end */
    //jal      ???
    7'b1101111:begin
        Branch      = 1'b1;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b1;
        ALUOp       = 3'b110;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b1;
        RegWrite    = 1'b1;
		jal_select  = 1'b1;
     end
    //jalr
    7'b1100111:begin
        Branch      = 1'b0;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b1;
        ALUOp       = 3'b100;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b1;
        RegWrite    = 1'b1;
		jal_select  = 1'b1;
     end
     default:  begin
        Branch      = 1'b0;  
        MemRead     = 1'b0;
        MemtoReg    = 1'b0;
        ALUOp       = 3'b000;
        MemWrite    = 1'b0;
        ALUSrc      = 1'b0;
        RegWrite    = 1'b0;
		jal_select  = 1'b0;
     end           
	 /* begin
        Branch      = 1'bx;  
        MemRead     = 1'bx;
        MemtoReg    = 1'bx;
        ALUOp       = 2'bxx;
        MemWrite    = 1'bx;
        ALUSrc      = 1'bx;
        RegWrite    = 1'bx;
     end */
    endcase
end
       
endmodule
