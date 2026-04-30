`include "ctrl_signal_def.v"

module EXT(imm_in, ExtSel, imm_out);
    input  [11:0] imm_in;     // 12位立即数输入
    input         ExtSel;     // 扩展控制信号
    output reg [31:0] imm_out; // 32位扩展结果

    always @(imm_in or ExtSel) begin
        case (ExtSel)
            `ExtSel_ZERO:
                imm_out = {20'b0, imm_in[11:0]};   // 零扩展

            `ExtSel_SIGNED:
                imm_out = { {20{imm_in[11]}}, imm_in[11:0] }; // 符号扩展

            default:
                imm_out = 32'b0;
        endcase
    end

endmodule