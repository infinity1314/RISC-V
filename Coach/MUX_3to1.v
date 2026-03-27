`include "ctrl_signal_def.v"

module MUX_3to1(X, Y, Z, control, out);
    input [4:0]  X;       // 对应指令中的 rd 字段
    input [4:0]  Y;       // 对应指令中的 rt 字段 (用于某些非标准或 I 型指令)
    input [4:0]  Z;       // 对应常数 5'd31 (用于 JAL 指令默认保存到 x31)
    input [1:0]  control; // 控制信号 RegSel
    output reg [4:0] out;

    always @ (X or Y or Z or control) begin
        case(control)
            `RegSel_rd   : out = X;   // 选择 rd
            `RegSel_rt   : out = Y;   // 选择 rt
            `RegSel_31   : out = Z;   // 选择 x31 (RA 寄存器)
            `RegSel_else : out = 5'b0;
            default      : out = 5'b0;
        endcase
    end

endmodule