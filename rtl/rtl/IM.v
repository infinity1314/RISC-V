`timescale 1ns / 1ps

module IM(
    input        clk,
    input        InsMemRW,      // 指令存储器读使能
    input  [11:2] addr,         // 地址（按字寻址）
    output reg [31:0] Ins       // 指令输出
);

// 1KB 指令存储器（1024条指令）
reg [31:0] memory [0:1023];

// ================= 读指令 =================
always @(posedge clk) begin
    // 当允许读时，从存储器取指令
    if (InsMemRW) begin
        Ins <= memory[addr];
    end
end

endmodule