`ifndef _CTRL
`define _CTRL
`include "Defines.vh"

// 流水线暂停与冲刷流水线控制模块
// 生成 stall[5:0]、id_flush、ex_flush 信号
module ctrl(
    input  wire        rst,

    // 各级发出的暂停请求
    input  wire        if_stall_req,
    input  wire        id_stall_req,

    // 分支 / 跳转 flush 信号
    input  wire        ex_b_flag_i,       // EX 阶段确认分支/跳转
    input  wire        id_flush_flag_i,   // ID 阶段提前判定的分支

    output reg [5:0]   stall,
    output reg         id_flush,
    output reg         ex_flush
);

    always @(*) begin
        // 默认值
        stall   = 6'b000000;
        id_flush = 1'b0;
        ex_flush = 1'b0;

        // 分支 / 跳转优先级最高
        if (ex_b_flag_i) begin
            // EX 已经确认需要跳转：flush EX 之前的指令
            ex_flush = 1'b1;
            // 此处也可以选择插入气泡，这里先不对 stall 做额外处理
        end else if (id_flush_flag_i) begin
            // ID 阶段（如 JAL/JALR/BRANCH）决定需要跳转
            id_flush = 1'b1;
        end
        // 其次处理数据冒险 / 取指等待导致的暂停
        else if (id_stall_req) begin
            // ID 请求暂停（例如 load-use 冒险）：
            //  - IF、ID 保持
            //  - EX 插入气泡
            stall = 6'b000111; // stall[0]=IF, [1]=ID, [2]=EX
        end else if (if_stall_req) begin
            // IF 请求暂停（取指等待）
            //  - IF 停住，ID 也不再接受新指令
            stall = 6'b000011; // stall[0]=IF, [1]=ID
        end
    end

endmodule
`endif

