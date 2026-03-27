`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit(
    input rst, clk, zero,
    input [6:0] opcode,
    input [6:0] Funct7,
    input [2:0] Funct3,
    output reg PCWrite, InsMemRW, IRWrite, RFWrite, DMCtrl, ExtSel, ALUSrcA,
    output reg [1:0] ALUSrcB, RegSel, NPCOp, WDSel,
    output reg [3:0] ALUOp
);

    // 状态定义（多周期 CPU 典型状态）
    parameter IF  = 3'b000; // 取指 (Instruction Fetch)
    parameter ID  = 3'b001; // 译码 (Instruction Decode)
    parameter EX  = 3'b010; // 执行 (Execute)
    parameter MEM = 3'b011; // 访存 (Memory Access)
    parameter WB  = 3'b100; // 写回 (Write Back)

    reg [2:0] curr_state, next_state;

    // 第一段：状态跳转逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) curr_state <= IF;
        else     curr_state <= next_state;
    end

    // 第二段：状态机转换逻辑
    always @(*) begin
        case(curr_state)
            IF:  next_state = ID;
            ID:  next_state = EX;
            EX:  begin
                if (opcode == `INSTR_ITYPE_L_OP || opcode == `INSTR_STYPE_OP) 
                    next_state = MEM; // Load/Store 指令需要经过 MEM
                else if (opcode == `INSTR_BTYPE_OP || opcode == `INSTR_JAL_OP || opcode == `INSTR_JALR_OP)
                    next_state = IF;  // 分支和跳转执行完直接回 IF
                else
                    next_state = WB;  // R型/I型算术指令进入 WB
            end
            MEM: begin
                if (opcode == `INSTR_ITYPE_L_OP) next_state = WB; // Load 指令需要 WB
                else                             next_state = IF; // Store 执行完回 IF
            end
            WB:  next_state = IF;
            default: next_state = IF;
        endcase
    end

    // 第三段：控制信号组合逻辑输出
    always @(*) begin
        // 默认值设置（防止产生锁存器 Latch）
        PCWrite = 0; InsMemRW = 0; IRWrite = 0; RFWrite = 0; 
        DMCtrl = 0; ExtSel = 0; ALUSrcA = 0;
        ALUSrcB = 2'b00; RegSel = 2'b00; NPCOp = `NPC_PC;
        WDSel = 2'b00; ALUOp = 4'b0000;

        case(curr_state)
            IF: begin
                InsMemRW = 1;
                IRWrite  = 1;
                PCWrite  = 1;
                NPCOp    = `NPC_PC; // PC = PC + 4
            end

            ID: begin
                // 预取立即数或分支地址计算
                ExtSel = (opcode == `INSTR_ITYPE_L_OP || opcode == `INSTR_ITYPE_A_OP) ? `ExtSel_SIGNED : `ExtSel_ZERO;
            end

            EX: begin
                // ALU 操作数 A 选择
                ALUSrcA = (opcode == `INSTR_JAL_OP || opcode == `INSTR_JALR_OP) ? 1 : 0;
                
                // ALU 操作数 B 选择
                if (opcode == `INSTR_RTYPE_OP) ALUSrcB = 2'b00; // 来自寄存器
                else                           ALUSrcB = 2'b01; // 来自立即数

                // ALUOp 计算逻辑（根据 Funct3/Funct7）
                case(opcode)
                    `INSTR_RTYPE_OP: begin
                        if (Funct3 == 3'b000) ALUOp = (Funct7[5]) ? `ALU_SUB : `ALU_ADD;
                        else if (Funct3 == 3'b111) ALUOp = `ALU_AND;
                        else if (Funct3 == 3'b110) ALUOp = `ALU_OR;
                        // ... 其他 R 型指令逻辑
                    end
                    `INSTR_ITYPE_A_OP: ALUOp = `ALU_ADD; // addi
                    `INSTR_BTYPE_OP:   ALUOp = `ALU_SUB; // 用于比较
                    default:           ALUOp = `ALU_ADD;
                endcase

                // 分支/跳转处理
                if (opcode == `INSTR_BTYPE_OP) begin
                    NPCOp = (zero) ? `NPC_OFFSET12 : `NPC_PC;
                    PCWrite = 1;
                end else if (opcode == `INSTR_JAL_OP) begin
                    NPCOp = `NPC_OFFSET20;
                    PCWrite = 1;
                end
            end

            MEM: begin
                if (opcode == `INSTR_ITYPE_L_OP) DMCtrl = 0; // Read
                else                             DMCtrl = 1; // Store (Write)
            end

            WB: begin
                RFWrite = 1;
                RegSel  = `RegSel_rd;
                WDSel   = (opcode == `INSTR_ITYPE_L_OP) ? 2'b01 : 2'b00; // Load 数据还是 ALU 结果
            end
        endcase
    end

endmodule