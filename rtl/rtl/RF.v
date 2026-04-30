`include "global_def.v"
`include "ctrl_signal_def.v"

module RF(
    input  [4:0] RR1,    // 读寄存器1地址
    input  [4:0] RR2,    // 读寄存器2地址
    input  [4:0] WR,     // 写寄存器地址
    input  [31:0] WD,    // 写数据
    input  RFWrite,      // 写使能
    input  clk,
    output [31:0] RD1,   // 读数据1
    output [31:0] RD2    // 读数据2
);

reg [31:0] register [0:31];   // 32个32位寄存器

// ================= 写寄存器 =================
always @(posedge clk) begin
    // x0恒为0
    register[0] <= 32'h0;

    if ((WR != 0) && (RFWrite == 1)) begin
        register[WR] <= WD;

`ifdef DEBUG
        // 打印寄存器内容（调试用）
        $display("R[0-7]=%8x %8x %8x %8x %8x %8x %8x %8x",
                 0, register[1], register[2], register[3],
                 register[4], register[5], register[6], register[7]);

        $display("R[8-15]=%8x %8x %8x %8x %8x %8x %8x %8x",
                 register[8], register[9], register[10], register[11],
                 register[12], register[13], register[14], register[15]);

        $display("R[16-23]=%8x %8x %8x %8x %8x %8x %8x %8x",
                 register[16], register[17], register[18], register[19],
                 register[20], register[21], register[22], register[23]);

        $display("R[24-31]=%8x %8x %8x %8x %8x %8x %8x %8x",
                 register[24], register[25], register[26], register[27],
                 register[28], register[29], register[30], register[31]);
`endif
    end
end

// ================= 读寄存器 =================
assign RD1 = register[RR1];
assign RD2 = register[RR2];

endmodule