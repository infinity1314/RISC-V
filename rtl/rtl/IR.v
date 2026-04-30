// 指令寄存器
`include "ctrl_signal_def.v"

module IR(in_ins, clk, IRWrite, out_ins);
    input        clk, IRWrite;   // 时钟、写使能
    input  [31:0] in_ins;        // 指令输入
    output reg [31:0] out_ins;   // 指令输出

    always @(posedge clk) begin
        if (IRWrite) begin
            out_ins = in_ins;
        end
    end

endmodule