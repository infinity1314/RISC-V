`include "ctrl_signal_def.v"

module EXT(imm_in, ExtSel, imm_out);
    input  [11:0]  imm_in;   // 指令中的 12 位立即数部分
    input          ExtSel;   // 扩展方式选择信号
    output reg [31:0] imm_out; // 扩展后的 32 位立即数

    always @(*) begin
        case(ExtSel)
            // 零扩展 (Zero Extension)
            `ExtSel_ZERO  : imm_out = {20'b0, imm_in[11:0]};
            
            // 符号位扩展 (Sign Extension)
            `ExtSel_SIGNED: imm_out = {imm_in[11] ? 20'hfffff : 20'h00000, imm_in[11:0]};
            
            default       : imm_out = 32'b0;
        endcase
    end

endmodule