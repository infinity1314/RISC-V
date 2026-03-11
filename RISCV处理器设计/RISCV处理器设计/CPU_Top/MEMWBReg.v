`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/07 13:39:15
// Design Name: 
// Module Name: MEMWBReg
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


module MEMWBReg(
    input               clk,
    input               reset_n,
    input               en,
    input [31:0]        PCAdd4_FromMEM, 
    output reg[31:0]    PCAdd4_ToWB,
    
    input [31:0]        ALUResult_FromMEM, 
    output reg[31:0]    ALUResult_ToWB,

    input [31:0]        MEMReadData_FromMEM, 
    output reg[31:0]    MEMReadData_ToWB,
    
    input [4:0]         WriteReg_FromMEM, 
    output reg[4:0]     WriteReg_ToWB,
    
    input               MemtoReg_FromMEM,
    input               RegWrite_FromMEM,
    input               J_FromMEM,
    
    output reg          MemtoReg_ToWB,
    output reg          RegWrite_ToWB,
    output reg          J_ToWB
    );
//////////////////////////////////////////////////////////
//PC   PC+4�Ĵ�
//////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) PCAdd4_ToWB<=32'h00000000;
    else if(en==1) PCAdd4_ToWB<=PCAdd4_FromMEM;
    else PCAdd4_ToWB<=PCAdd4_ToWB;
end    
//////////////////////////////////////////////////////////
//ALUResult �Ĵ���
//////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) ALUResult_ToWB<=32'h00000000;
    else if(en==1) ALUResult_ToWB<=ALUResult_FromMEM;
    else ALUResult_ToWB<=ALUResult_ToWB;
end
//////////////////////////////////////////////////////////
//ALUResult �Ĵ���
//////////////////////////////////////////////////////////
always @ (posedge clk) begin
    if(!reset_n) MEMReadData_ToWB<='b0;
    else if(en==1) MEMReadData_ToWB<=MEMReadData_FromMEM;
    else MEMReadData_ToWB<=MEMReadData_ToWB;
end
//////////////////////////////////////////////////////////
//�Ĵ�����  ���������Ĵ�
//////////////////////////////////////////////////////////    
always @ (posedge clk) begin
    if(!reset_n) 
    begin
        WriteReg_ToWB       <='b0;
    end
    else if(en==1) 
    begin
        WriteReg_ToWB       <=WriteReg_FromMEM;
    end
    else 
    begin
        WriteReg_ToWB       <=WriteReg_ToWB    ;
    end
end
//////////////////////////////////////////////////////////
//�����źżĴ���
//////////////////////////////////////////////////////////    
always @ (posedge clk) begin
    if(!reset_n) 
    begin
        MemtoReg_ToWB   <='b0;
        RegWrite_ToWB   <='b0;
        J_ToWB          <='b0;
    end
    else if(en==1) 
    begin
        MemtoReg_ToWB   <=MemtoReg_FromMEM ;  
        RegWrite_ToWB   <=RegWrite_FromMEM ;  
        J_ToWB          <=J_FromMEM        ;     
    end
    else 
    begin
        MemtoReg_ToWB   <=MemtoReg_ToWB;
        RegWrite_ToWB   <=RegWrite_ToWB;
        J_ToWB          <=J_ToWB       ;
    end
end        
    
endmodule
