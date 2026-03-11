`ifndef _EX
`define _EX
`include "Defines.vh"
`include "IDInstDef.vh"
`include "ALUInstDef.vh"

module EX(
    input wire rst,
    input wire clk,
    input wire reset,
    
    input wire [`InstAddrBus] ex_pc_i,
    input wire [`AluOpBus] ex_aluop_i,
    input wire [`AluOutSelBus] ex_alusel_i,
    input wire [`RegBus] ex_r1_data_i,
    input wire [`RegBus] ex_r2_data_i,
    input wire ex_w_enable_i,
    input wire [`RegAddrBus] ex_w_addr_i,

    output wire [`RegBus] ex_w_data_o,
    output wire ex_w_b_flag_o,
    output wire [`InstAddrBus] ex_w_b_target_addr_o,

    input wire me_pre_ld,
    input wire me_w_enable_i,
    input wire [`RegAddrBus] me_w_addr_i,
    input wire [`RegBus] me_w_data_i,
);
endmodule