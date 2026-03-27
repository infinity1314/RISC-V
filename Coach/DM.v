`include "ctrl_signal_def.v"

module DM(Addr, WD, clk, DMCtrl, RD);
    input  [11:2] Addr;    // 数据存储器地址（字对齐，1024字容量）
    input  [31:0] WD;      // 写入存储器的数据
    input         clk;     // 时钟信号
    input         DMCtrl;  // 数据存储器写使能信号 (1:写, 0:读)
    output reg [31:0] RD;  // 从存储器读出的数据

    // 定义 1024 个 32 位存储单元 (共 4KB)
    reg [31:0] memory[0:1023];

    // 时钟上升沿处理写操作
    always @(posedge clk) begin
        if (DMCtrl) begin
            memory[Addr] <= WD; // 执行存储 (Store)
        end
        else begin
            RD <= memory[Addr]; // 执行加载 (Load)
        end
    end
 // end always

endmodule