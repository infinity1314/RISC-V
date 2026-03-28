`include "ctrl_signal_def.v"
`include "instruction_def.v"

module NPC(NPCOp, Offset12, Offset20, PC, rs, PCA4, NPC);
    input [1:0]  NPCOp;      // 控制信号：选择下一跳地址的来源
    input [12:1] Offset12;   // B型指令偏移量 (Branch)
    input [20:1] Offset20;   // J型指令偏移量 (Jump)
    input [31:0] PC;         // 当前指令地址
    input [31:0] rs;         // 寄存器读出的地址 (用于 JALR)
    
    output reg [31:0] PCA4;  // 当前 PC + 4，用于保存返回地址
    output reg [31:0] NPC;   // 下一跳目标地址

    wire signed [12:0] Offset13;
    wire signed [20:0] Offset21;

    // 符号位扩展并补上最低位的 0 (RISC-V 指令偏移量通常是半字对齐的)
    assign Offset13 = $signed({Offset12[12:1], 1'b0});
    assign Offset21 = $signed({Offset20[20:1], 1'b0});

    always @(*) begin
        case(NPCOp)
            `NPC_PC        : NPC = PC + 4;
            `NPC_Offset12 : NPC = $signed({1'b0, PC}) + $signed(Offset13);
            `NPC_rs        : NPC = rs;
            `NPC_Offset20  : NPC = $signed({1'b0, PC}) + $signed(Offset21);
            default       : NPC = PC + 4;
        endcase
        PCA4 = PC + 4; // 计算返回地址，通常用于保存到寄存器堆的 X1/X31
    end

endmodule