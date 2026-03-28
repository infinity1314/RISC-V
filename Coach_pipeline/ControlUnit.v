`timescale 1ns / 1ps
// 多周期 CPU 控制单元：与赛方给出的 PC / IR / Flopr / DM / NPC 等模块配合。
// 状态：IF -> ID -> EXE -> (MEM 仅 lw/sw) -> (WB 需写回类) -> 下一指令 IF
// PC 仅在一条指令执行完毕时更新（PCWrite=1），取指周期保持 PC 不变。

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit(
    input  wire        rst,
    input  wire        clk,
    input  wire        zero,
    input  wire [6:0]  opcode,
    input  wire [6:0]  Funct7,
    input  wire [2:0]  Funct3,
    output reg         PCWrite,
    output reg         InsMemRW,
    output reg         IRWrite,
    output reg         RFWrite,
    output reg         DMCtrl,
    output reg         ExtSel,
    output reg         ALUSrcA,
    output reg [1:0]   ALUSrcB,
    output reg [1:0]   RegSel,
    output reg [1:0]   NPCOp,
    output reg [1:0]   WDSel,
    output reg [3:0]   ALUOp
);

    localparam S_IF  = 3'd0;
    localparam S_ID  = 3'd1;
    localparam S_EXE = 3'd2;
    localparam S_MEM = 3'd3;
    localparam S_WB  = 3'd4;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S_IF;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            S_IF:  next_state = S_ID;
            S_ID:  next_state = S_EXE;
            S_EXE: begin
                case (opcode)
                    `INSTR_BTYPE_OP: next_state = S_IF;
                    `INSTR_LW_OP,
                    `INSTR_SW_OP:   next_state = S_MEM;
                    default:        next_state = S_WB;
                endcase
            end
            S_MEM: begin
                if (opcode == `INSTR_LW_OP)
                    next_state = S_WB;
                else
                    next_state = S_IF;
            end
            S_WB:  next_state = S_IF;
            default: next_state = S_IF;
        endcase
    end

    always @(*) begin
        PCWrite  = 1'b0;
        InsMemRW = 1'b1;
        IRWrite  = 1'b0;
        RFWrite  = 1'b0;
        DMCtrl   = `DMCtrl_RD;
        ExtSel   = `ExtSel_SIGNED;
        ALUSrcA  = `ALUSrcA_A;
        ALUSrcB  = `ALUSrcB_B;
        RegSel   = `RegSel_rd;
        NPCOp    = `NPC_PC;
        WDSel    = `WDSel_FromALU;
        ALUOp    = `ALUOp_ADD;

        case (state)
            S_IF: begin
                IRWrite  = 1'b1;
                InsMemRW = 1'b1;
            end

            S_ID: begin
            end

            S_EXE: begin
                case (opcode)
                    `INSTR_RTYPE_OP: begin
                        ALUSrcB = `ALUSrcB_B;
                        case (Funct3)
                            `FUNCT3_ADD_SUB: ALUOp = Funct7[5] ? `ALUOp_SUB : `ALUOp_ADD;
                            `FUNCT3_AND:     ALUOp = `ALUOp_AND;
                            `FUNCT3_OR:      ALUOp = `ALUOp_OR;
                            `FUNCT3_XOR:     ALUOp = `ALUOp_XOR;
                            `FUNCT3_SLL:     ALUOp = `ALUOp_SLL;
                            `FUNCT3_SRL_SRA: ALUOp = Funct7[5] ? `ALUOp_SRA : `ALUOp_SRL;
                            default:         ALUOp = `ALUOp_ADD;
                        endcase
                    end

                    `INSTR_ITYPE_OP: begin
                        ALUSrcB = `ALUSrcB_Imm;
                        case (Funct3)
                            `INSTR_ADDI_FUNCT: ALUOp = `ALUOp_ADD;
                            `INSTR_ORI_FUNCT: begin
                                ALUOp  = `ALUOp_OR;
                                ExtSel = `ExtSel_ZERO;
                            end
                            default: ALUOp = `ALUOp_ADD;
                        endcase
                    end

                    `INSTR_LW_OP,
                    `INSTR_SW_OP: begin
                        ALUSrcB = `ALUSrcB_Imm;
                        ALUOp   = `ALUOp_ADD;
                    end

                    `INSTR_BTYPE_OP: begin
                        ALUSrcB = `ALUSrcB_B;
                        ALUOp   = `ALUOp_BR;
                        case (Funct3)
                            `INSTR_BEQ_FUNCT: NPCOp = zero  ? `NPC_Offset12 : `NPC_PC;
                            `INSTR_BNE_FUNCT: NPCOp = ~zero ? `NPC_Offset12 : `NPC_PC;
                            default:          NPCOp = `NPC_PC;
                        endcase
                        PCWrite = 1'b1;
                    end

                    `INSTR_JAL_OP: begin
                    end

                    `INSTR_JALR_OP: begin
                        ExtSel  = `ExtSel_SIGNED;
                        ALUSrcB = `ALUSrcB_Imm;
                        ALUOp   = `ALUOp_ADD;
                    end

                    default: ;
                endcase
            end

            S_MEM: begin
                case (opcode)
                    `INSTR_LW_OP: DMCtrl = `DMCtrl_RD;
                    `INSTR_SW_OP: begin
                        DMCtrl  = `DMCtrl_WR;
                        NPCOp   = `NPC_PC;
                        PCWrite = 1'b1;
                    end
                    default: ;
                endcase
            end

            S_WB: begin
                PCWrite = 1'b1;
                case (opcode)
                    `INSTR_RTYPE_OP: begin
                        RFWrite = 1'b1;
                        WDSel   = `WDSel_FromALU;
                        NPCOp   = `NPC_PC;
                    end
                    `INSTR_ITYPE_OP: begin
                        RFWrite = 1'b1;
                        WDSel   = `WDSel_FromALU;
                        NPCOp   = `NPC_PC;
                        case (Funct3)
                            `INSTR_ORI_FUNCT: ExtSel = `ExtSel_ZERO;
                            default: ;
                        endcase
                    end
                    `INSTR_LW_OP: begin
                        RFWrite = 1'b1;
                        WDSel   = `WDSel_FromMEM;
                        NPCOp   = `NPC_PC;
                    end
                    `INSTR_JAL_OP: begin
                        RFWrite = 1'b1;
                        RegSel  = `RegSel_rd;
                        WDSel   = `WDSel_FromPC;
                        NPCOp   = `NPC_Offset20;
                    end
                    `INSTR_JALR_OP: begin
                        RFWrite = 1'b1;
                        RegSel  = `RegSel_rd;
                        WDSel   = `WDSel_FromPC;
                        NPCOp   = `NPC_rs;
                    end
                    default: begin
                        NPCOp = `NPC_PC;
                    end
                endcase
            end

            default: ;
        endcase
    end

endmodule
