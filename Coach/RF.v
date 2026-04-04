`include "global_def.v"
`include "ctrl_signal_def.v"

module RF(
    input  [4:0]  RR1,      // 读取寄存器 1 地址
    input  [4:0]  RR2,      // 读取寄存器 2 地址
    input  [4:0]  WR,       // 写入寄存器地址
    input  [31:0] WD,       // 写入数据
    input         RFWrite,  // 寄存器堆写使能
    input         clk,      // 时钟信号
    output [31:0] RD1,      // 输出寄存器 1 数据
    output [31:0] RD2       // 输出寄存器 2 数据
);

    // 定义 32 个 32 位寄存器
    reg [31:0] register [0:31];

    // 时钟上升沿：单 always 内完成写回，避免综合报多驱动（x0 仅最后一拍清零）
    always @(posedge clk) begin
        if (RFWrite == 1'b1 && WR != 5'd0) begin
            register[WR] <= WD;
            `ifdef DEBUG
                $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
                $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
                $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
                $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
            `endif
        end
        // x0 恒为 0：单独一条赋值，与其它寄存器写入互斥（WR!=0 时不会写 x0）
        register[0] <= 32'h0;
    end

    // 组合逻辑读取：根据输入地址立即输出数据
    assign RD1 = register[RR1];
    assign RD2 = register[RR2];

endmodule