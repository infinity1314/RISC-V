`timescale 1ns / 1ps
`include "ctrl_signal_def.v"

module IM(InsMemRW, addr, Ins);
    input         InsMemRW; // 指令存储器读使能信号
    input  [11:2] addr;     // 指令地址（字对齐）
    input  clk;
    output reg [31:0] Ins;  // 输出的指令码

    // 定义 1024 个 32 位指令存储单元
    reg [31:0] memory[0:1023];

    // 组合逻辑读取（根据地址实时输出指令）
    always @(posedge clk) begin
        if (InsMemRW) begin
            Ins <= memory[addr]; // 读取指令
        end
        else begin
            Ins <= 32'h00000013; // 默认输出 NOP 指令 (addi x0, x0, 0)
        end
    end

endmodule