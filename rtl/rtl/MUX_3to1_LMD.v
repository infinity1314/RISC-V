`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module MUX_3to1_LMD(X, Y, Z, control, out);
    input  [31:0] X;   // ALU结果
    input  [31:0] Y;   // 数据存储器读出
    input  [31:0] Z;   // PC+4
    input  [1:0]  control;
    output reg [31:0] out;

    always @(X or Y or Z or control) begin
        case (control)
            `WDSel_FromALU: out = X;
            `WDSel_FromMEM: out = Y;
            `WDSel_FromPC:  out = Z;
            `WDSel_else:    out = 0;
        endcase
    end

endmodule