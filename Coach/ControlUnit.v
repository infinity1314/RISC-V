`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit(
    input rst,
    input clk,
    input zero,            // 在流水线中，分支判断通常提前到 ID 阶段
    input [6:0] opcode,
    input [6:0] Funct7,
    input [2:0] Funct3,
    output reg PCWrite,    // 用于处理流水线冒险时的暂停 (Stall)
    output reg InsMemRW,   // 指令存储器读写 (通常恒为读)
    output reg IRWrite,    // 流水线中通常对应 IF/ID 寄存器的使能
    output reg RFWrite,    // 是否写回寄存器堆 (最终传到 WB 阶段)
    output reg DMCtrl,     // 数据存储器读写 (1:写, 0:读，传到 MEM 阶段)
    output reg ExtSel,     // 立即数扩展方式
    output reg ALUSrcA,    // ALU A端来源 (0:RD1, 1:SA/PC)
    output reg [1:0] ALUSrcB, // ALU B端来源 (0:RD2, 1:Imm, 2:Offset)
    output reg [1:0] RegSel,  // 写回目标选择 (rd/rt/x31)
    output reg [1:0] NPCOp,   // 下一跳地址选择
    output reg [1:0] WDSel,   // 写回数据来源 (ALU/MEM/PC+4)
    output reg [3:0] ALUOp    // ALU 运算类型控制
);

    always @(*) begin
        // --- 默认信号设置（避免产生锁存器） ---
        PCWrite  = 1'b1;   // 默认 PC 始终更新
        InsMemRW = 1'b1;   // 默认读指令
        IRWrite  = 1'b1;   // 默认流水线寄存器流动
        RFWrite  = 1'b0;
        DMCtrl   = `DMCtrl_RD;
        ExtSel   = `ExtSel_SIGNED;
        ALUSrcA  = `ALUSrcA_A;
        ALUSrcB  = `ALUSrcB_B;
        RegSel   = `RegSel_rd;
        NPCOp    = `NPC_PC;
        WDSel    = `WDSel_FromALU;
        ALUOp    = `ALUOp_ADD;

        case(opcode)
            // R-Type 指令 (add, sub, and, or, slt, etc.)
            `INSTR_RTYPE_OP: begin
                RFWrite = 1'b1;
                ALUSrcB = `ALUSrcB_B;
                WDSel   = `WDSel_FromALU;
                case(Funct3)
                    3'b000: ALUOp = (Funct7[5]) ? `ALUOp_SUB : `ALUOp_ADD;
                    3'b111: ALUOp = `ALUOp_AND;
                    3'b110: ALUOp = `ALUOp_OR;
                    3'b100: ALUOp = `ALUOp_XOR;
                    3'b001: ALUOp = `ALUOp_SLL;
                    3'b101: ALUOp = (Funct7[5]) ? `ALUOp_SRA : `ALUOp_SRL;
                    default: ALUOp = `ALUOp_ADD;
                endcase
            end

            // I-Type 算术指令 (addi, ori, etc.)
            `INSTR_ITYPE_OP: begin
                RFWrite = 1'b1;
                ALUSrcB = `ALUSrcB_Imm;
                WDSel   = `WDSel_FromALU;
                case(Funct3)
                    3'b000: ALUOp = `ALUOp_ADD; // addi
                    3'b110: begin 
                        ALUOp = `ALUOp_OR;   // ori
                        ExtSel = `ExtSel_ZERO;
                    end
                    default: ALUOp = `ALUOp_ADD;
                endcase
            end

            // I-Type Load 指令 (lw)
            `INSTR_LW_OP: begin
                RFWrite = 1'b1;
                ALUSrcB = `ALUSrcB_Imm;
                DMCtrl  = `DMCtrl_RD;
                WDSel   = `WDSel_FromMEM;
                ALUOp   = `ALUOp_ADD;
            end

            // S-Type Store 指令 (sw)
            `INSTR_SW_OP: begin
                RFWrite = 1'b0;
                ALUSrcB = `ALUSrcB_Imm;
                DMCtrl  = `DMCtrl_WR;
                ALUOp   = `ALUOp_ADD;
            end

            // B-Type 分支指令 (beq, bne)
            `INSTR_BTYPE_OP: begin
                ALUSrcB = `ALUSrcB_B;
                ALUOp   = `ALUOp_BR;   // 使用专门的分支比较逻辑
                NPCOp   = (zero) ? `NPC_Offset12 : `NPC_PC;
                // 流水线中通常需要在此处清空 (Flush) 已经取错的指令
            end

            // J-Type 跳转指令 (jal)
            `INSTR_JAL_OP: begin
                RFWrite = 1'b1;
                RegSel  = `RegSel_31;  // 返回地址存入 x31
                WDSel   = `WDSel_FromPC;
                NPCOp   = `NPC_Offset20;
            end

            default: ;
        endcase
    end

endmodule