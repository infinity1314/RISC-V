`ifndef _EX_MEM
`define _EX_MEM
`include "Defines.vh"
`include "ALUInstDef.vh"

// EX_MEM：将 EX 阶段的计算结果、写回信息打拍到 MEM 阶段
module EX_MEM(
    input  wire                 clk,
    input  wire                 rst,

    // 来自 EX 阶段
    input  wire[`AluOpBus]      ex_aluop_i,
    input  wire[`RegBus]        ex_w_data_o,   // 一般为 ALU 结果或地址
    input  wire[`RegBus]        ex_r2_data_i,  // 用于 STORE 的写数据
    input  wire                 ex_w_enable_i,
    input  wire[`RegAddrBus]    ex_w_addr_i,

    // 送往 MEM 阶段
    output reg [`AluOpBus]      me_aluop_i,
    output reg [`RegBus]        me_addr_i,     // 地址 / 运算结果
    output reg [`RegBus]        me_r2_data_i,  // STORE 写数据
    output reg                  me_w_enable_i,
    output reg [`RegAddrBus]    me_w_addr_i
);

    always @(posedge clk) begin
        if (rst) begin
            me_aluop_i    <= `EX_NOP_OP;
            me_addr_i     <= `Zero;
            me_r2_data_i  <= `Zero;
            me_w_enable_i <= `WriteDisable;
            me_w_addr_i   <= `NOPRegAddr;
        end else begin
            me_aluop_i    <= ex_aluop_i;
            me_addr_i     <= ex_w_data_o;
            me_r2_data_i  <= ex_r2_data_i;
            me_w_enable_i <= ex_w_enable_i;
            me_w_addr_i   <= ex_w_addr_i;
        end
    end

endmodule
`endif
