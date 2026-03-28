`timescale 1ns / 1ps
`include "ctrl_signal_def.v"

module MUX_3to1_LMD(X, Y, Z, control, out);
    input [31:0] X;       // 来自 ALU 的结果 (ALU_result)
    input [31:0] Y;       // 来自数据存储器的数据 (RD)
    input [31:2] Z;       // 来自 PC 的返回地址 (PC+4)，注意这里截取了 31:2
    input [1:0]  control; // 控制信号 WDSel
    output reg [31:0] out;

    always @ (X or Y or Z or control) begin
        case(control)
            `WDSel_FromALU : out = X;            // 选择 ALU 结果
            `WDSel_FromMEM : out = Y;            // 选择内存读取结果 (Load)
            `WDSel_FromPC  : out = {Z, 2'b00};   // 选择 PC+4 (用于跳转指令保存返回地址)
            `WDSel_Else    : out = 32'b0;
            default        : out = 32'b0;
        endcase
    end

endmodule