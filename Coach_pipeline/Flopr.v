`include "ctrl_signal_def.v"

module Flopr(clk, rst, in_data, out_data);
    input             clk;      // 时钟信号
    input             rst;      // 异步复位信号
    input      [31:0] in_data;  // 输入数据
    output reg [31:0] out_data; // 输出数据

    // 异步复位：rst 高电平时立即清零，不看时钟
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_data <= 0;      // 复位清零
        end 
        else begin
            out_data <= in_data; // 正常工作：每个上升沿锁存一次数据
        end
    end

endmodule