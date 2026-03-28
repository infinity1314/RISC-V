// Coach RISC-V 控制信号宏（与 ControlUnit / ALU / NPC / MUX 一致）
// 被 `include 到各模块；勿在多个文件重复定义同名宏。

// ---------- NPC：下一 PC 来源 ----------
`define NPC_PC         2'b00   // 顺序 PC+4
`define NPC_Offset12   2'b01   // B 型分支：PC + imm
`define NPC_rs         2'b10   // JALR：寄存器基址 + 立即数（目标在 riscv 组合算出）
`define NPC_Offset20   2'b11   // JAL：PC + imm

// ---------- ALU 输入 A（MUX_2to1_A）----------
`define ALUSrcA_A      1'b0    // A = RD1_r
`define ALUSrcA_sa     1'b1    // A = {27'b0, shamt}（当前顶层未用，保留）

// ---------- ALU 输入 B（MUX_3to1_B）----------
`define ALUSrcB_B       2'b00  // B = RD2_r
`define ALUSrcB_Imm     2'b01  // B = 扩展后 Imm32
`define ALUSrcB_Offset  2'b10  // B = 符号扩展的 12 位 Offset（分支用 RD2 时一般不用）
`define ALUSrcB_else    2'b11

// ---------- 立即数扩展（EXT）----------
`define ExtSel_ZERO     1'b0   // 零扩展（ori）
`define ExtSel_SIGNED   1'b1   // 符号扩展（addi/lw/sw/jalr 等）

// ---------- ALU 运算（4 位，与 ALU.v case 一一对应）----------
`define ALUOp_ADD       4'b0000
`define ALUOp_SUB       4'b0001
`define ALUOp_AND       4'b0010
`define ALUOp_OR        4'b0011
`define ALUOp_XOR       4'b0100
`define ALUOp_SRA       4'b0111
`define ALUOp_SLL       4'b1000
`define ALUOp_SRL       4'b1001
// 分支：做 A-B，用 zero=(结果==0) 判断相等；beq 用 zero，bne 用 ~zero
`define ALUOp_BR        4'b1010

// ---------- 寄存器写地址（MUX_3to1 5bit）----------
`define RegSel_rd       2'b00
`define RegSel_rt       2'b01
`define RegSel_31       2'b10   // 保留；标准 JAL 应写 rd，建议用 RegSel_rd
`define RegSel_else     2'b11

// ---------- 写回数据来源（MUX_3to1_LMD）----------
`define WDSel_FromALU   2'b00
`define WDSel_FromMEM   2'b01
`define WDSel_FromPC    2'b10   // PC+4（jal/jalr 链接）
`define WDSel_Else      2'b11

// ---------- 数据存储器 ----------
`define DMCtrl_RD       1'b0
`define DMCtrl_WR       1'b1
