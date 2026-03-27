`include "ctrl_signal_def.v"

module MUX_2to1_A(X, Y, control, out);
    input [31:0] X;       // 对应 RD1 数据
    input [4:0]  Y;       // 对应指令中的 rs1/shamt 字段
    input        control; // 选择控制信号 ALUSrcA
    output [31:0] out;

    // 组合逻辑选择：0 选 X，1 选 Y（并进行高位补零）
    assign out = (control == 1'b0 ? X : {27'b0, Y[4:0]});

endmodule