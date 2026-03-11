`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/07 13:39:15
// Design Name: 
// Module Name: IFIDReg
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


module IFIDReg(
    input               clk,
    input               reset_n,
    input               en,
    input [31:0]        instruction_FromIF, 
    output reg[31:0]    instruction_ToID,
    
    input [31:0]        PC_FromIF, 
    output reg[31:0]    PC_ToID,
    
    input [31:0]        PCAdd4_FromIF, 
    output reg[31:0]    PCAdd4_ToID
    );
always @ (posedge clk) begin
    if(!reset_n) instruction_ToID<=32'h00000000;
    else if(en==1) instruction_ToID<=instruction_FromIF;
    else instruction_ToID<=instruction_ToID;
end

always @ (posedge clk) begin
    if(!reset_n) PC_ToID<=32'h00000000;
    else if(en==1) PC_ToID<=PC_FromIF;
    else PC_ToID<=PC_ToID;
end

always @ (posedge clk) begin
    if(!reset_n) PCAdd4_ToID<=32'h00000000;
    else if(en==1) PCAdd4_ToID<=PCAdd4_FromIF;
    else PCAdd4_ToID<=PCAdd4_ToID;
end
endmodule
