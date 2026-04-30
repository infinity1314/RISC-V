`include "ctrl_signal_def.v"
`include "instruction_def.v"

module NPC(
    NPCOp, Offset12, Offset20, PC, rs, PC4A, NPC
);
    input  [1:0]  NPCOp;
    input  [11:0] Offset12;
    input  [20:1] Offset20;
    input  [31:0] PC;
    input  [31:0] rs;
    output reg [31:0] PC4A;
    output reg [31:0] NPC;

    wire signed [12:0] Offset13;
    wire signed [20:0] Offset21;
    wire [31:0] PCadd4;
    wire [31:0] pc_plus_off12;
    wire [31:0] pc_plus_off20;

    // 偏移扩展（注意左移1位）
    assign Offset13 = $signed({Offset12[12:1], 1'b0});
    assign Offset21 = $signed({Offset20[20:1], 1'b0});

    assign PCadd4        = PC + 32'd4;
    assign pc_plus_off12 = $signed(PC) + $signed(Offset13);
    assign pc_plus_off20 = $signed(PC) + $signed(Offset21);

    always @(*) begin
        case (NPCOp)
            `NPC_PC:       NPC = PCadd4;          // PC + 4
            `NPC_offset12: NPC = pc_plus_off12;   // 分支
            `NPC_rs:       NPC = rs;              // jalr
            `NPC_offset20: NPC = pc_plus_off20;   // jal
        endcase
    end

    // 输出PC+4
    always @(*) begin
        PC4A = PCadd4;
    end

endmodule