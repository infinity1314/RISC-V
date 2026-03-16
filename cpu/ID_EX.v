//ID_EX模块，负责将ID模块传来的指令和PC地址传到EX模块
//输入：clk，时钟信号
//输入：rst，复位信号
//输入：id_pc，ID模块传来的PC地址
//输入：id_aluop_o，ID模块传来的ALU操作码
//输入：id_alusel_o，ID模块传来的ALU选择器
//输入：id_r1_data_o，ID模块传来的寄存器1数据
//输入：id_r2_data_o，ID模块传来的寄存器2数据
//输入：id_w_enable_o，ID模块传来的写使能
//输入：id_w_addr_o，ID模块传来的写地址

//输出：ex_aluop_i，EX模块要传入的ALU操作码
//输出：ex_alusel_i，EX模块要传入的ALU选择器
//输出：ex_r1_data_i，EX模块要传入的寄存器1数据
//输出：ex_r2_data_i，EX模块要传入的寄存器2数据
//输出：ex_w_enable_i，EX模块要传入的写使能
//输出：ex_w_addr_i，EX模块要传入的写地址
//输出：ex_pc_i，EX模块要传入的PC地址
//输出：ex_offset_i，EX模块要传入的偏移量
//输入：ex_b_flag_i，EX模块传来的分支标志
//输入：ex_w_b_target_addr_o，EX模块传来的分支目标地址
`ifndef _ID_EX
`define _ID_EX
`include "Defines.vh"
`include "IDInstDef.vh"
`include "ALUInstDef.vh"

module ID_EX(
    input wire clk,
    input wire reset,
    
    input wire [`InstAddrBus]   id_pc,

    input wire [`AluOpBus]      id_aluop_o,
    input wire [`AluOutSelBus]  id_alusel_o,
    output reg [`AluOpBus]      ex_aluop_i,
    output reg [`AluOutSelBus]  ex_alusel_i,

    input wire [`RegBus]        id_r1_data_o,
    input wire [`RegBus]        id_r2_data_o,
    output reg [`RegBus]        ex_r1_data_i,
    output reg [`RegBus]        ex_r2_data_i,
    input wire                  id_w_enable_o,
    output reg                  ex_w_enable_i,
    input wire [`RegAddrBus]    id_w_addr_o,
    output reg [`RegAddrBus]    ex_w_addr_i,

    output reg[`InstAddrBus]    ex_pc_i,

    input wire[`RegBus]         id_offset_o,
    output reg[`RegBus]         ex_offset_i,

    input wire                  ex_b_flag_i,
    input wire[5:0]             stall,
    
);
reg flush;
initial flush = 1'b0;
always @(posedge clk) begin
    if (reset) begin
        ex_aluop_i      <= `ALUOp_NOP;
        ex_alusel_i     <= `ALUSel_NOP;
        ex_r1_data_i    <= `Zero;
        ex_r2_data_i    <= `Zero;
        ex_w_enable_i   <= `WriteDisable;
        ex_w_addr_i     <= `NOPRegAddr;
        ex_pc_i         <= `Zero;
        ex_offset_i     <= `Zero;
        flush           <= 1'b0;
    end else begin
        if (ex_b_flag_i)begin
            if(stall[2] && !stall[3])begin
                ex_aluop_i      <= `ALUOp_NOP;
                ex_alusel_i     <= `ALUSel_NOP;
                ex_r1_data_i    <= `Zero;
                ex_r2_data_i    <= `Zero;
                ex_w_enable_i   <= `WriteDisable;
                ex_w_addr_i     <= `NOPRegAddr;
                ex_pc_i         <= `Zero;
                ex_offset_i     <= `Zero;
            end else if(stall[2] && stall[3])begin
                flush           <= 1'b1;
            end else begin
                ex_aluop_i      <= `ALUOp_NOP;
                ex_alusel_i     <= `ALUSel_NOP;
                ex_r1_data_i    <= `Zero;
                ex_r2_data_i    <= `Zero;
                ex_w_enable_i   <= `WriteDisable;
                ex_w_addr_i     <= `NOPRegAddr;
                ex_pc_i         <= `Zero;
                ex_offset_i     <= `Zero;
                flush           <= 1'b0;
            end
        end 
        else if(stall[2] && !stall[3])begin
            ex_aluop_i      <= `ALUOp_NOP;
            ex_alusel_i     <= `ALUSel_NOP;
            ex_r1_data_i    <= `Zero;
            ex_r2_data_i    <= `Zero;
            ex_w_enable_i   <= `WriteDisable;
            ex_w_addr_i     <= `NOPRegAddr;
            ex_pc_i         <= `Zero;
            ex_offset_i     <= `Zero;

        end else if (!stall[2])begin
            if (flush)begin
                ex_aluop_i      <= `ALUOp_NOP;
                ex_alusel_i     <= `ALUSel_NOP;
                ex_r1_data_i    <= `Zero;
                ex_r2_data_i    <= `Zero;
                ex_w_enable_i   <= `WriteDisable;
                ex_w_addr_i     <= `NOPRegAddr;
                ex_pc_i         <= `Zero;
                ex_offset_i     <= `Zero;
            end else begin
                ex_aluop_i      <= id_aluop_o;
                ex_alusel_i     <= id_alusel_o;
                ex_r1_data_i    <= id_r1_data_o;
                ex_r2_data_i    <= id_r2_data_o;
                ex_w_enable_i   <= id_w_enable_o;
                ex_w_addr_i     <= id_w_addr_o;
                ex_pc_i         <= id_pc;
                ex_offset_i     <= id_offset_o;
            end
        end
    end
end


endmodule
`endif