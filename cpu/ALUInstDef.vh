`ifndef _ALU_INST_DEF
`define _ALU_INST_DEF

// ALU 操作码总线宽度（8bit 足够覆盖当前所有 EX_*）
`define AluOpBus        7:0

// EX 阶段结果类型选择总线宽度（3bit 就够）
`define AluOutSelBus    2:0

// ===== ALUOp（EX_***_OP）定义 =====
`define EX_NOP_OP       8'h00   // 空操作

// 逻辑运算
`define EX_OR_OP        8'h01
`define EX_AND_OP       8'h02
`define EX_XOR_OP       8'h03

// 算术运算
`define EX_ADD_OP       8'h10
`define EX_SUB_OP       8'h11
`define EX_SLT_OP       8'h12
`define EX_SLTU_OP      8'h13
`define EX_AUIPC_OP     8'h14   // AUIPC: PC + imm

// 移位
`define EX_SLL_OP       8'h20
`define EX_SRL_OP       8'h21
`define EX_SRA_OP       8'h22

// 分支/跳转（主要用于控制，不太依赖 ALU 结果）
`define EX_JAL_OP       8'h30
`define EX_JALR_OP      8'h31
`define EX_BEQ_OP       8'h32
`define EX_BNE_OP       8'h33
`define EX_BLT_OP       8'h34
`define EX_BGE_OP       8'h35
`define EX_BLTU_OP      8'h36
`define EX_BGEU_OP      8'h37

// Load/Store（地址计算）
`define EX_LB_OP        8'h40
`define EX_LH_OP        8'h41
`define EX_LW_OP        8'h42
`define EX_LBU_OP       8'h43
`define EX_LHU_OP       8'h44
`define EX_SB_OP        8'h48
`define EX_SH_OP        8'h49
`define EX_SW_OP        8'h4A

// 兼容 ID_EX 里用的命名
`define ALUOp_NOP       `EX_NOP_OP

// ===== ALU 结果选择（alusel_o） =====
`define EX_RES_NOP      3'b000  // 无结果
`define EX_RES_LOGIC    3'b001  // 逻辑运算结果
`define EX_RES_ARITH    3'b010  // 加减/比较等算术结果
`define EX_RES_SHIFT    3'b011  // 移位结果
`define EX_RES_LD_ST    3'b100  // Load/Store 地址
`define EX_RES_J_B      3'b101  // JAL/JALR/BRANCH 等跳转写回结果（通常 PC+4）

// 兼容 ID_EX 里用的命名
`define ALUSel_NOP      `EX_RES_NOP

`endif