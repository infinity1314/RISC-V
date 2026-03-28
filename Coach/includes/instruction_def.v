`timescale 1ns / 1ps
// RV32I 指令 opcode（7 位）——比赛 16 条指令均在此集合内

`define INSTR_RTYPE_OP   7'b0110011  // R：add/sub/and/or/xor/sll/srl/sra
`define INSTR_ITYPE_OP   7'b0010011  // I：addi, ori
`define INSTR_BTYPE_OP   7'b1100011  // B：beq, bne
`define INSTR_LW_OP      7'b0000011  // I：lw
`define INSTR_SW_OP      7'b0100011  // S：sw
`define INSTR_JAL_OP     7'b1101111  // J：jal
`define INSTR_JALR_OP    7'b1100111  // I：jalr

// B 型 funct3
`define INSTR_BEQ_FUNCT  3'b000
`define INSTR_BNE_FUNCT  3'b001

// I 型算术/立即数 funct3（与比赛指令对应部分）
`define INSTR_ADDI_FUNCT 3'b000
`define INSTR_ORI_FUNCT  3'b110

// Load/Store 字访问 funct3
`define INSTR_LW_FUNCT   3'b010
`define INSTR_SW_FUNCT   3'b010

// JALR 固定 funct3 = 000
`define INSTR_JALR_FUNCT 3'b000

// R 型 funct3（便于测试平台或扩展）
`define FUNCT3_ADD_SUB   3'b000
`define FUNCT3_SLL       3'b001
`define FUNCT3_XOR       3'b100
`define FUNCT3_SRL_SRA   3'b101
`define FUNCT3_OR        3'b110
`define FUNCT3_AND       3'b111
