`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/07 13:39:15
// Design Name: 
// Module Name: IDEXReg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IDEXReg(
    input               clk,
    input               reset_n,
    input               en,
    input [31:0]        PC_FromID, 
    output reg[31:0]    PC_ToEX,
    input [31:0]        PCAdd4_FromID, 
    output reg[31:0]    PCAdd4_ToEX,
    
    input [31:0]        Imm_FromID, 
    output reg[31:0]    Imm_ToEX,
    
    input [31:0]        RegReadData1_FromID, 
    output reg[31:0]    RegReadData1_ToEX,
    input [31:0]        RegReadData2_FromID, 
    output reg[31:0]    RegReadData2_ToEX,
    input [4:0]         RegRead1_FromID, 
    output reg[4:0]     RegRead1_ToEX,
    input [4:0]         RegRead2_FromID, 
    output reg[4:0]     RegRead2_ToEX,
    input [4:0]         WriteReg_FromID, 
    output reg[4:0]     WriteReg_ToEX,
        
    input               Branch_FromID,
    input               MemRead_FromID,
    input               MemtoReg_FromID,
    input[2:0]          ALUOp_FromID,
    input               MemWrite_FromID,
    input               ALUSrc_FromID,
    input               RegWrite_FromID,
    input               J_FromID,
    
    output reg          Branch_ToEX,
    output reg          MemRead_ToEX,
    output reg          MemtoReg_ToEX,
    output reg[2:0]     ALUOp_ToEX,
    output reg          MemWrite_ToEX,
    output reg          ALUSrc_ToEX,
    output reg          RegWrite_ToEX,
    output reg          J_ToEX,
    
    input [4:0]         Func3Fun7_FromID, 
    output reg[4:0]     Func3Fun7_ToEX
    );
//////////////////////////////////////////////////////////
//PC   PC+4
//////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) PC_ToEX<=32'h00000000;
    else if(en==1) PC_ToEX<=PC_FromID;
    else PC_ToEX<=PC_ToEX;
end
always @ (posedge clk) begin
    if(!reset_n) PCAdd4_ToEX<=32'h00000000;
    else if(en==1) PCAdd4_ToEX<=PCAdd4_FromID;
    else PCAdd4_ToEX<=PCAdd4_ToEX;
end
//////////////////////////////////////////////////////////
//����������Ĵ�?
//////////////////////////////////////////////////////////    
always @ (posedge clk) begin
    if(!reset_n) Imm_ToEX<='b0;
    else if(en==1) Imm_ToEX<=Imm_FromID;
    else Imm_ToEX<=Imm_ToEX;
end
//////////////////////////////////////////////////////////
//�Ĵ�����  ���������Ĵ�
//////////////////////////////////////////////////////////    
always @ (posedge clk) begin
    if(!reset_n) 
    begin
        RegReadData1_ToEX   <='b0;
        RegReadData2_ToEX   <='b0;
        RegRead1_ToEX       <='b0;
        RegRead2_ToEX       <='b0;
        WriteReg_ToEX       <='b0;
    end
    else if(en==1) 
    begin
        RegReadData1_ToEX   <=RegReadData1_FromID;
        RegReadData2_ToEX   <=RegReadData2_FromID;
        RegRead1_ToEX       <=RegRead1_FromID;
        RegRead2_ToEX       <=RegRead2_FromID;
        WriteReg_ToEX       <=WriteReg_FromID;
    end
    else 
    begin
        RegReadData1_ToEX   <=RegReadData1_ToEX;
        RegReadData2_ToEX   <=RegReadData2_ToEX;
        RegRead1_ToEX       <=RegRead1_ToEX    ;
        RegRead2_ToEX       <=RegRead2_ToEX    ;
        WriteReg_ToEX       <=WriteReg_ToEX    ;
    end
end
//////////////////////////////////////////////////////////
//�����źżĴ���
//////////////////////////////////////////////////////////    
always @ (posedge clk) begin
    if(!reset_n) 
    begin
        Branch_ToEX     <='b0;
        MemRead_ToEX    <='b0;
        MemtoReg_ToEX   <='b0;
        ALUOp_ToEX      <='b0; 
        MemWrite_ToEX   <='b0; 
        ALUSrc_ToEX     <='b0; 
        RegWrite_ToEX   <='b0;
        J_ToEX          <='b0;
    end
    else if(en==1) 
    begin
        Branch_ToEX     <=Branch_FromID   ;  
        MemRead_ToEX    <=MemRead_FromID  ;  
        MemtoReg_ToEX   <=MemtoReg_FromID ;  
        ALUOp_ToEX      <=ALUOp_FromID    ;  
        MemWrite_ToEX   <=MemWrite_FromID ;  
        ALUSrc_ToEX     <=ALUSrc_FromID   ;  
        RegWrite_ToEX   <=RegWrite_FromID ;  
        J_ToEX          <=J_FromID        ;     
    end
    else 
    begin
        Branch_ToEX     <=Branch_ToEX  ;
        MemRead_ToEX    <=MemRead_ToEX ;
        MemtoReg_ToEX   <=MemtoReg_ToEX;
        ALUOp_ToEX      <=ALUOp_ToEX   ;
        MemWrite_ToEX   <=MemWrite_ToEX;
        ALUSrc_ToEX     <=ALUSrc_ToEX  ;
        RegWrite_ToEX   <=RegWrite_ToEX;
        J_ToEX          <=J_ToEX       ;
    end
end
//////////////////////////////////////////////////////////////////
//// Func3,Func7 /////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) Func3Fun7_ToEX<='b0;
    else if(en==1) Func3Fun7_ToEX<=Func3Fun7_FromID;
    else Func3Fun7_ToEX<=Func3Fun7_ToEX;
end
endmodule
