`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/07 13:39:15
// Design Name: 
// Module Name: EXMEMReg
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


module EXMEMReg(
    input               clk,
    input               reset_n,
    input               en,
    input [31:0]        PCAdd4_FromEX, 
    output reg[31:0]    PCAdd4_ToMEM,
    
    input [31:0]        ALUResult_FromEX, 
    output reg[31:0]    ALUResult_ToMEM,
    input [31:0]        RegReadData2_FromEX, 
    output reg[31:0]    RegReadData2_ToMEM,
    
    input [4:0]         WriteReg_FromEX, 
    output reg[4:0]     WriteReg_ToMEM,
    
    input               MemRead_FromEX,
    input               MemtoReg_FromEX,
    input               MemWrite_FromEX,
    input               RegWrite_FromEX,
    input               J_FromEX,
    
    output reg          MemRead_ToMEM,
    output reg          MemtoReg_ToMEM,
    output reg          MemWrite_ToMEM,
    output reg          RegWrite_ToMEM,
    output reg          J_ToMEM
    );
//////////////////////////////////////////////////////////
//PC   PC+4�Ĵ�
//////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) PCAdd4_ToMEM<='b0;
    else if(en==1) PCAdd4_ToMEM<=PCAdd4_FromEX;
    else PCAdd4_ToMEM<=PCAdd4_ToMEM;
end    
//////////////////////////////////////////////////////////
//ALUResult �Ĵ���
//////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) ALUResult_ToMEM<='b0;
    else if(en==1) ALUResult_ToMEM<=ALUResult_FromEX;
    else ALUResult_ToMEM<=ALUResult_ToMEM;
end

//////////////////////////////////////////////////////////
//��ȡ�ĵڶ������ݼĴ���
//////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) RegReadData2_ToMEM<='b0;
    else if(en==1) RegReadData2_ToMEM<=RegReadData2_FromEX;
    else RegReadData2_ToMEM<=RegReadData2_ToMEM;
end
//////////////////////////////////////////////////////////
//�Ĵ�����  ���������Ĵ�
//////////////////////////////////////////////////////////    
always @ (posedge clk) begin
    if(!reset_n) 
    begin
        WriteReg_ToMEM       <='b0;
    end
    else if(en==1) 
    begin
        WriteReg_ToMEM       <=WriteReg_FromEX;
    end
    else 
    begin
        WriteReg_ToMEM       <=WriteReg_ToMEM    ;
    end
end
//////////////////////////////////////////////////////////
//�����źżĴ���
//////////////////////////////////////////////////////////    
always @ (posedge clk) begin
    if(!reset_n) 
    begin
        MemRead_ToMEM    <='b0;
        MemtoReg_ToMEM   <='b0;
        MemWrite_ToMEM   <='b0; 
        RegWrite_ToMEM   <='b0;
        J_ToMEM          <='b0;
    end
    else if(en==1) 
    begin
        MemRead_ToMEM    <=MemRead_FromEX  ;  
        MemtoReg_ToMEM   <=MemtoReg_FromEX ;  
        MemWrite_ToMEM   <=MemWrite_FromEX ;  
        RegWrite_ToMEM   <=RegWrite_FromEX ;  
        J_ToMEM          <=J_FromEX        ;     
    end
    else 
    begin
        MemRead_ToMEM    <=MemRead_ToMEM ;
        MemtoReg_ToMEM   <=MemtoReg_ToMEM;
        MemWrite_ToMEM   <=MemWrite_ToMEM;
        RegWrite_ToMEM   <=RegWrite_ToMEM;
        J_ToMEM          <=J_ToMEM       ;
    end
end    
endmodule
