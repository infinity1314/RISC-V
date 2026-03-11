module ForwardingUnit(
    input     [4:0]     Reg32Source1_From_IDEX,
    input     [4:0]     Reg32Source2_From_IDEX,
	input     [4:0]     Reg32Source1_From_ID,//解决回写与译码冲突问题
    input     [4:0]     Reg32Source2_From_ID,//解决回写与译码冲突问题
    input     [0:0]     WriteRegEn_From_MEM, 
    input     [4:0]     WriteReg_From_MEM,           
    input     [0:0]     WriteRegEn_From_WB, 
    input     [4:0]     WriteReg_From_WB, 
    input     [0:0]     ALUSrc_From_ID, //ALU Src2来自谁 立即数/寄存器
          
    output    reg[1:0]  ALUSrc1Ctrl_To_ALUSrc1,
    output    reg[1:0]  ALUSrc2Ctrl_To_ALUSrc2,
    output    reg[1:0]  IDEXRegSrc1Ctrl_To_IDEXRegSrc1MUX,//解决回写与译码冲突问题
    output    reg[1:0]  IDEXRegSrc2Ctrl_To_IDEXRegSrc2MUX,//解决回写与译码冲突问题
    output    reg[1:0]  EXMEMRegSrc2Ctrl_To_EXMEMRegSrc2MUX//解决 SW指令问题（Src2正在MEM一级，未回写）
);  
//////////////////////////////////////////////////////////////////          
//ALUSrc1Ctrl_To_ALUSrc1产生 00 来自寄存器堆，10来自旁路1,11来自旁路2       
//////////////////////////////////////////////////////////////////          
always @ (*) begin
    ALUSrc1Ctrl_To_ALUSrc1 = 2'b00;
    if((WriteRegEn_From_MEM==1) && (Reg32Source1_From_IDEX != 0) && (Reg32Source1_From_IDEX == WriteReg_From_MEM))//MEM优先级比WB优先级高
        begin
                ALUSrc1Ctrl_To_ALUSrc1=2'b10;//10选择旁路1做为ALU源操作数
        end
    else if((WriteRegEn_From_WB == 1) && (Reg32Source1_From_IDEX != 0) && (Reg32Source1_From_IDEX == WriteReg_From_WB))
        begin
                ALUSrc1Ctrl_To_ALUSrc1=2'b11;//10选择旁路2做为ALU源操作数
        end
end        
//////////////////////////////////////////////////////////////////          
//ALUSrc2Ctrl_To_ALUSrc1产生 00 来自寄存器堆，01来自立即数，10来自旁路1,11来自旁路2       
//////////////////////////////////////////////////////////////////
always @ (*)
begin
    ALUSrc2Ctrl_To_ALUSrc2 = 2'b00;
    if(ALUSrc_From_ID ==1) ALUSrc2Ctrl_To_ALUSrc2 = 2'b01;//优先判断立即数
    else if((WriteRegEn_From_MEM==1) && (Reg32Source2_From_IDEX != 0) && (Reg32Source2_From_IDEX == WriteReg_From_MEM))//MEM优先级比WB优先级高
        begin
                ALUSrc2Ctrl_To_ALUSrc2=2'b10;//10选择旁路1做为ALU源操作数
        end
    else if((WriteRegEn_From_WB == 1) && (Reg32Source2_From_IDEX != 0) && (Reg32Source2_From_IDEX == WriteReg_From_WB))
        begin
                ALUSrc2Ctrl_To_ALUSrc2=2'b11;//10选择旁路2做为ALU源操作数
        end
end 




//////////////////////////////////////////////////////////////////          
//IDEXRegSrc1Ctrl_To_IDEXRegSrc1MUX产生 00 来自寄存器堆，10来自旁路1,11来自旁路2       
//////////////////////////////////////////////////////////////////          
always @ (*) begin
    IDEXRegSrc1Ctrl_To_IDEXRegSrc1MUX = 2'b00;
    if((WriteRegEn_From_MEM==1) && (Reg32Source1_From_ID != 0) && (Reg32Source1_From_ID == WriteReg_From_MEM))//MEM优先级比WB优先级高
        begin
                IDEXRegSrc1Ctrl_To_IDEXRegSrc1MUX=2'b10;//
        end
    else if((WriteRegEn_From_WB == 1) && (Reg32Source1_From_ID != 0) && (Reg32Source1_From_ID == WriteReg_From_WB))
        begin
                IDEXRegSrc1Ctrl_To_IDEXRegSrc1MUX=2'b11;//
        end
end  

//////////////////////////////////////////////////////////////////          
//IDEXRegSrc1Ctr2_To_IDEXRegSrc2MUX产生 00 来自寄存器堆，10来自旁路1,11来自旁路2       
//////////////////////////////////////////////////////////////////          
always @ (*) begin
    IDEXRegSrc2Ctrl_To_IDEXRegSrc2MUX = 2'b00;
    if((WriteRegEn_From_MEM==1) && (Reg32Source2_From_ID != 0) && (Reg32Source2_From_ID == WriteReg_From_MEM))//MEM优先级比WB优先级高
        begin
                IDEXRegSrc2Ctrl_To_IDEXRegSrc2MUX=2'b10;//
        end
    else if((WriteRegEn_From_WB == 1) && (Reg32Source2_From_ID != 0) && (Reg32Source2_From_ID == WriteReg_From_WB))
        begin
                IDEXRegSrc2Ctrl_To_IDEXRegSrc2MUX=2'b11;
        end
end  


//////////////////////////////////////////////////////////////////          
//EXMEMRegSrc2Ctrl_To_EXMEMRegSrc2MUX产生 00 来自寄存器堆，10来自旁路1  
//////////////////////////////////////////////////////////////////          
always @ (*) begin
    EXMEMRegSrc2Ctrl_To_EXMEMRegSrc2MUX = 2'b00;
    if((WriteRegEn_From_MEM==1) && (Reg32Source2_From_IDEX != 0) && (Reg32Source2_From_IDEX == WriteReg_From_MEM))//MEM优先级比WB优先级高
        begin
                EXMEMRegSrc2Ctrl_To_EXMEMRegSrc2MUX=2'b10;
        end
end                   
endmodule