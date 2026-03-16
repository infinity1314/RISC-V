`ifndef _BRANCH_PREDICTOR
`define _BRANCH_PREDICTOR
`include "Defines.vh"

// 简单的直接映射分支预测器：
// - 64 项 BTB，每项包含 tag、目标地址、1-bit taken
// - 查询：IF 阶段用 pc_i 访问
// - 更新：EX 阶段用实际分支结果更新
module branch_predictor(
    input  wire                 clk,
    input  wire                 rst,

    // 查询端口（IF 阶段）
    input  wire[`InstAddrBus]   pc_i,
    output wire                 pred_taken_o,
    output wire[`InstAddrBus]   pred_target_o,

    // 更新端口（EX 阶段）
    input  wire                 update_valid_i,
    input  wire[`InstAddrBus]   update_pc_i,
    input  wire                 update_taken_i,
    input  wire[`InstAddrBus]   update_target_i
);

    // 参数：表大小为 64 项
    localparam ENTRY_NUM      = 64;
    localparam INDEX_WIDTH    = 6;                    // log2(64)
    localparam TAG_WIDTH      = `InstAddrWidth - 2 - INDEX_WIDTH;

    // BTB / BHT 表项定义
    reg                        valid    [0:ENTRY_NUM-1];
    reg[TAG_WIDTH-1:0]         tag      [0:ENTRY_NUM-1];
    reg[`InstAddrBus]          target   [0:ENTRY_NUM-1];
    reg                        taken    [0:ENTRY_NUM-1];  // 1-bit history

    integer i;

    // 查询索引/tag
    wire[INDEX_WIDTH-1:0]      q_index  = pc_i[INDEX_WIDTH+1:2];
    wire[TAG_WIDTH-1:0]        q_tag    = pc_i[`InstAddrWidth-1:INDEX_WIDTH+2];

    // 命中判断
    wire hit = valid[q_index] && (tag[q_index] == q_tag);

    assign pred_taken_o  = hit && taken[q_index];
    assign pred_target_o = target[q_index];

    // 更新索引/tag
    wire[INDEX_WIDTH-1:0]      u_index  = update_pc_i[INDEX_WIDTH+1:2];
    wire[TAG_WIDTH-1:0]        u_tag    = update_pc_i[`InstAddrWidth-1:INDEX_WIDTH+2];

    // 更新逻辑
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < ENTRY_NUM; i = i + 1) begin
                valid[i]  <= 1'b0;
                tag[i]    <= {TAG_WIDTH{1'b0}};
                target[i] <= {`InstAddrWidth{1'b0}};
                taken[i]  <= 1'b0;
            end
        end else if (update_valid_i) begin
            valid[u_index]  <= 1'b1;
            tag[u_index]    <= u_tag;
            target[u_index] <= update_target_i;
            taken[u_index]  <= update_taken_i;
        end
    end

endmodule
`endif

