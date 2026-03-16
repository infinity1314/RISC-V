`ifndef _ICACHE
`define _ICACHE
`include "Defines.vh"

// 简单直接映射指令 Cache：
// - 行大小：1 条 32bit 指令
// - 行数：64 行
// - 接口对 IF 看起来像一个带 busy/done 的 ROM
// - 底下再连真实指令存储器（外部 ROM）
module icache(
    input  wire                 clk,
    input  wire                 rst,

    // 来自 IF 的取指请求
    input  wire[`InstAddrBus]   if_pc_i,
    input  wire                 if_req_i,       // 取指请求（原来的 r_enable_o）
    output reg [`InstBus]       if_inst_o,
    output reg                  if_busy_o,      // miss 或等待底层存储器时为 1
    output reg                  if_done_o,      // 指令有效时为 1

    // 底层真实指令存储器接口（相当于原来的 rom_*）
    output reg [`InstAddrBus]   mem_addr_o,
    output reg                  mem_en_o,
    input  wire[`InstBus]       mem_data_i,
    input  wire                 mem_busy_i,
    input  wire                 mem_done_i
);

    localparam LINE_NUM    = 64;
    localparam INDEX_WIDTH = 6;                    // log2(64)
    localparam TAG_WIDTH   = `InstAddrWidth - 2 - INDEX_WIDTH;

    // Cache 行：valid + tag + data
    reg                     valid   [0:LINE_NUM-1];
    reg[TAG_WIDTH-1:0]      tag     [0:LINE_NUM-1];
    reg[`InstBus]           data    [0:LINE_NUM-1];

    integer i;

    // 查询索引/tag
    wire[INDEX_WIDTH-1:0]   index   = if_pc_i[INDEX_WIDTH+1:2];
    wire[TAG_WIDTH-1:0]     q_tag   = if_pc_i[`InstAddrWidth-1:INDEX_WIDTH+2];

    wire                    hit     = valid[index] && (tag[index] == q_tag);

    // 简单 FSM：IDLE / MISS
    localparam S_IDLE = 1'b0;
    localparam S_MISS = 1'b1;
    reg state;

    // 记录 miss 时的 PC（用于填充）
    reg[`InstAddrBus] miss_pc;

    always @(posedge clk) begin
        if (rst) begin
            state      <= S_IDLE;
            mem_en_o   <= 1'b0;
            mem_addr_o <= `Zero;
            for (i = 0; i < LINE_NUM; i = i + 1) begin
                valid[i] <= 1'b0;
                tag[i]   <= {TAG_WIDTH{1'b0}};
                data[i]  <= {`InstWidth{1'b0}};
            end
        end else begin
            case (state)
                S_IDLE: begin
                    mem_en_o <= 1'b0;
                    if (if_req_i && !hit) begin
                        // 发生 miss：向底层存储器发出请求
                        state      <= S_MISS;
                        miss_pc    <= if_pc_i;
                        mem_addr_o <= if_pc_i;
                        mem_en_o   <= 1'b1;
                    end
                end
                S_MISS: begin
                    // 等待底层存储器完成
                    if (mem_done_i) begin
                        // 填充 cache 行
                        // 重新计算 index/tag（使用 miss_pc）
                        // 防止 IF_pc 已经变化
                        // 注意：与上面的 index/q_tag 不同，用 miss_pc
                        // 这里只用组合表达式即可
                        //  index_m = miss_pc[INDEX_WIDTH+1:2];
                        //  tag_m   = miss_pc[InstAddrWidth-1:INDEX_WIDTH+2];
                        // 但在时序块中用临时变量避免多驱动
                        begin : fill_block
                            reg[INDEX_WIDTH-1:0] index_m;
                            reg[TAG_WIDTH-1:0]   tag_m;
                            index_m = miss_pc[INDEX_WIDTH+1:2];
                            tag_m   = miss_pc[`InstAddrWidth-1:INDEX_WIDTH+2];
                            valid[index_m] <= 1'b1;
                            tag[index_m]   <= tag_m;
                            data[index_m]  <= mem_data_i;
                        end
                        state    <= S_IDLE;
                        mem_en_o <= 1'b0;
                    end
                end
            endcase
        end
    end

    // 输出到 IF（组合逻辑）
    always @(*) begin
        if_inst_o = `Zero;
        if_busy_o = 1'b0;
        if_done_o = 1'b0;

        case (state)
            S_IDLE: begin
                if (if_req_i && hit) begin
                    if_inst_o = data[index];
                    if_done_o = 1'b1;
                    if_busy_o = 1'b0;
                end else if (if_req_i && !hit) begin
                    // 正在发起 miss 请求
                    if_busy_o = 1'b1;
                    if_done_o = 1'b0;
                end
            end
            S_MISS: begin
                // miss 处理中：对 IF 而言 busy=1，直到 mem_done_i
                if_busy_o = 1'b1;
                if_done_o = 1'b0;
            end
        endcase
    end

endmodule
`endif

