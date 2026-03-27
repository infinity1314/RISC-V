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

    // 硬件强制：X0 寄存器永远等于 0，任何写入操作对 X0 无效
    always @(clk) begin
        register[0] = 32'h0;
    end

    // 时钟上升沿写入逻辑
    always @(posedge clk) begin
        // 只有当写使能有效且目标寄存器不是 X0 时才执行写入
        if ((WR != 0) && (RFWrite == 1)) begin
            register[WR] <= WD;
            
            `ifdef DEBUG
                // 仿真时打印所有寄存器的值，方便调试
                $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
                $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
                $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
                $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
            `endif
        end
    end

    // 组合逻辑读取：根据输入地址立即输出数据
    assign RD1 = register[RR1];
    assign RD2 = register[RR2];

endmodule