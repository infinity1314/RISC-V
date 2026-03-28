`include "ctrl_signal_def.v"

module IR(clk, IRWrite, in_ins, out_ins);
    input             clk;      // 时钟信号
    input             IRWrite;  // 指令寄存器写使能
    input      [31:0] in_ins;   // 输入的指令（来自 IM）
    output reg [31:0] out_ins;  // 输出的指令（发送给控制器和译码逻辑）

    always @(posedge clk) begin
        // 只有当写使能有效时，才更新保存的指令
        if (IRWrite) begin
            out_ins <= in_ins;
        end
    end

endmodule