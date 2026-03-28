// NPC 控制信号：决定下一条指令地址的来源
`define NPC_PC        2'b00   // 顺序执行 (PC + 4)
`define NPC_Offset12  2'b01   // B型分支跳转 (Branch)
`define NPC_rs        2'b10   // JALR 跳转 (寄存器地址)
`define NPC_Offset20  2'b11   // J型直接跳转 (Jump)

// ALU 操作数 A 选择信号
`define ALUSrcA_A     1'b0    // 选择寄存器堆读出的 RD1
`define ALUSrcA_sa    1'b1    // 选择指令中的位移量 (Shift Amount)

// ALU 操作数 B 选择信号
`define ALUSrcB_B      2'b00  // 选择寄存器堆读出的 RD2
`define ALUSrcB_Imm    2'b01  // 选择 32 位扩展立即数
`define ALUSrcB_Offset 2'b10  // 选择偏移量
`define ALUSrcB_else   2'b11  // 默认/其他情况

// 立即数扩展控制信号
`define ExtSel_ZERO    1'b0   // 零扩展 (用于逻辑运算)
`define ExtSel_SIGNED  1'b1   // 符号位扩展 (用于算术运算)

// ALU 功能控制信号 (ALUOp)
`define ALUOp_ADD      4'b0000 // 加法
`define ALUOp_SUB      4'b0001 // 减法
`define ALUOp_AND      4'b0010 // 按位与
`define ALUOp_OR       4'b0011 // 按位或
`define ALUOp_XOR      4'b0100 // 按位异或
`define ALUOp_SRA      4'b0111 // 算术右移
`define ALUOp_SLL      4'b1000 // 逻辑左移
`define ALUOp_SRL      4'b1001 // 逻辑右移
`define ALUOp_BR       4'b1010 // 分支比较 (Branch Compare)

// 寄存器堆 (RF) 控制信号
`define RegSel_rd      2'b00  // 写回指令指定的 rd
`define RegSel_rt      2'b01  // 写回指令指定的 rt
`define RegSel_31      2'b10  // 写回 x31 (RA 寄存器)
`define RegSel_else    2'b11  // 默认

`define WDSel_FromALU  2'b00  // 寄存器写回源：ALU 运算结果
`define WDSel_FromMEM  2'b01  // 寄存器写回源：内存读取数据
`define WDSel_FromPC   2'b10  // 寄存器写回源：返回地址 (PC+4)
`define WDSel_Else     2'b11  // 默认

// 数据存储器 (DM) 控制信号
`define DMCtrl_RD      1'b0   // 内存读
`define DMCtrl_WR      1'b1   // 内存写