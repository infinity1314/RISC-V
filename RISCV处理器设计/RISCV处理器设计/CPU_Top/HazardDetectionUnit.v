module HazardDetectionUnit(
/////////////////////////////////////////////////////
////分支预测部分信号
/////////////////////////////////////////////////////
    input     [31:0]    PCADD4_From_EX,
    input     [31:0]    ALUResult_From_EX,
    input     [31:0]    PCADDimm_From_EX, 
    input     [0:0]     Branch_From_EX, //  1       1       0
    input     [0:0]     J_From_EX,      //  0       1       1
    input     [0:0]     Zero_From_EX,   //  B指令   JAL     JALR
      
    output    [0:0]     PCSourceMux_To_PCSourceMux,//控制PC源的多路选择器 
    output    [0:0]     JumpCtrl_To_PC, //控制PC的信号源
    output    [0:0]     IF_IDReset_To_IF_IDReg, 
    output    [0:0]     ID_EXReset_To_ID_EXReg, 
    
/////////////////////////////////////////////////////
////空指令部分信号
/////////////////////////////////////////////////////          
    input     [4:0]     Source1_From_ID, 
    input     [4:0]     Source2_From_ID, 
    input     [4:0]     Rd_From_EX, 
    input     [0:0]     MemRead_From_EX, 
          
    output    [0:0]     PC_En_To_PC,
    output    [0:0]     IF_IDEn_To_IF_IDReg
); 
/////////////////////////////////////////////////////
////分支预测部分信号控制
/////////////////////////////////////////////////////
wire NextAdd_NEQ_PCAdd4; 
assign PCSourceMux_To_PCSourceMux = Branch_From_EX;
//跳转信号控制：J指令跳转的地址与下一条指令不同则跳转        B指令，当 跳转的地址与下一条指令不同时  并且 Zero ==1 则跳转
assign JumpCtrl_To_PC = ( J_From_EX & NextAdd_NEQ_PCAdd4) | ((J_From_EX==0) & Branch_From_EX & NextAdd_NEQ_PCAdd4 & Zero_From_EX);
assign IF_IDReset_To_IF_IDReg =~ JumpCtrl_To_PC ;
wire  NOPID_EXReset = PC_En_To_PC; 
assign ID_EXReset_To_ID_EXReg =(~ JumpCtrl_To_PC) & ( NOPID_EXReset ) ;
wire [31:0] NextAddSel;
//选择与PC+4比较的信号
assign NextAddSel=(PCSourceMux_To_PCSourceMux==1)? PCADDimm_From_EX : ALUResult_From_EX; 
assign NextAdd_NEQ_PCAdd4 = ( NextAddSel != PCADD4_From_EX);

/////////////////////////////////////////////////////
////数据冲突部分信号控制
/////////////////////////////////////////////////////
wire Rs1_EQ_Rd;
wire Rs2_EQ_Rd;
assign Rs1_EQ_Rd = (Source1_From_ID ==  Rd_From_EX) && (Source1_From_ID != 0);
assign Rs2_EQ_Rd = (Source2_From_ID ==  Rd_From_EX) && (Source2_From_ID != 0);

assign PC_En_To_PC = !(MemRead_From_EX & ( Rs1_EQ_Rd | Rs2_EQ_Rd ));  
assign IF_IDEn_To_IF_IDReg = PC_En_To_PC;
                                                                                        
endmodule