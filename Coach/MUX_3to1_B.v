module MUX_3to1_B(X, Y, Z, control, out);
    input  [31:0] X;       // 来自寄存器堆的数据 RD2
    input  [31:0] Y;       // 来自 EXT 的 32 位扩展立即数 Imm32
    input  [11:0] Z;       // 12 位偏移量 Offset
    input  [1:0]  control; // 控制信号 ALUSrcB
    output reg signed [31:0] out;

    always @ (X or Y or Z or control) begin
        case(control)
            `ALUSrcB_B      : out = X;           // 选择寄存器数据
            `ALUSrcB_Imm    : out = Y;           // 选择立即数
            `ALUSrcB_Offset : out = $signed(Z);  // 对 12 位 Offset 进行有符号扩展并输出
            `ALUSrcB_else   : out = X;           // 默认选项
            default         : out = X;
        endcase
    end
endmodule