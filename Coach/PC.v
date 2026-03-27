`include "ctrl_signal_def.v"

module PC(clk, rst, PCWrite, NPC, PC);
    input              clk;        // 时钟信号
    input              rst;        // 复位信号
    input              PCWrite;    // PC写使能控制信号
    input      [31:0]  NPC;        // 由NPC模块计算出的下一跳地址
    output reg [31:0]  PC;         // 当前指令的地址

    // 异步复位，同步更新
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 叩持杯项目通常将 PC 复位到 0x0000_2000，即指令存储器的起始地址
            PC <= 32'h0000_2000;  
        end 
        else if (PCWrite) begin
            PC <= NPC;             // 只有在 PCWrite 有效时才更新地址（用于处理流水线暂停等）
        end
    end

endmodule