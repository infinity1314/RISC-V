module cpuLSX(
	input    clk,
	input    reset_n,
	output[31:0] Address_Ins,
	input [31:0] Instruction,
	output[31:0]  Data_Mem_Address,
	output [31:0] Data_Mem_WriteData,
	output [0:0] MemWrite,
	output [0:0] MemRead,
	input [31:0] DataMenoryOut,//给定地址和读信号后下个周期出数据
	output Hit,
	output PCI_MEM_Ctrl//外设 1 /内存 0 访问控制
);
wire CLK_CPU = clk&Hit;
wire NextPCSel_FromHazardDetectionUnit_To_PC;
wire PCEN_FromHazardDetectionUnit_To_PC;
wire[31:0] NextPCSSource_FromPCSourceMUX_To_PC;
wire[31:0] PCADD4_FromPC_To_IFIDReg;
///////////////////////////////////////////////    取指    //////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////    取指    //////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////    取指    //////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//程序计数器///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
PC u_pc(
   .clk(clk),
   .rest(reset_n),
   .sel(NextPCSel_FromHazardDetectionUnit_To_PC),
   .source(NextPCSSource_FromPCSourceMUX_To_PC),
   .en(PCEN_FromHazardDetectionUnit_To_PC&Hit),
   .pc(Address_Ins),
   .pcadd4(PCADD4_FromPC_To_IFIDReg)
);
///////////////////////////////////////////////////////////////////////////////
//选择下一个PC的值/////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
wire[31:0] PCAddImm_FromEX_PCSourceMUX;
wire[31:0] ALUResult_FromALU_To_EX_MEMReg;
wire PCSourceMux_FromHazardDetectionUnit_To_PCSourceMux;
mux MUXNEXTPC(
	.source1(ALUResult_FromALU_To_EX_MEMReg),
	.source2(PCAddImm_FromEX_PCSourceMUX),
	.source3(1'b0),
	.source4(1'b0),
	.select({1'b0,PCSourceMux_FromHazardDetectionUnit_To_PCSourceMux}),
	.result(NextPCSSource_FromPCSourceMUX_To_PC)
);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////IF/ID缓冲///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
wire IF_IDReset_FromHazardDetectionUnit_To_IF_IDReg;
wire IF_IDEn_FromHazardDetectionUnit_To_IF_IDReg;
wire[31:0] Instruction_FromIF_IDReg_To_ID;
wire[31:0] NowPC_FromIF_IDReg_To_ID_EXReg;
wire[31:0] NowPCADD4_FromIF_IDReg_To_ID_EXReg;
IFIDReg  IFIDReg_u(
    .clk(clk),
    .reset_n(reset_n&IF_IDReset_FromHazardDetectionUnit_To_IF_IDReg),
    .en(IF_IDEn_FromHazardDetectionUnit_To_IF_IDReg&Hit),
    .instruction_FromIF(Instruction), 
    .instruction_ToID(Instruction_FromIF_IDReg_To_ID),//
    
    .PC_FromIF(Address_Ins), 
    .PC_ToID(NowPC_FromIF_IDReg_To_ID_EXReg),//
    
    .PCAdd4_FromIF(PCADD4_FromPC_To_IFIDReg), 
    .PCAdd4_ToID(NowPCADD4_FromIF_IDReg_To_ID_EXReg)//
    );
wire[31:0] ALUResultFromEX_MEMReg_To_MEM_WBReg; 
wire[31:0] RegReadData1_FromID_ToID_EXRegMUX1;    
wire[31:0] RegReadData2_FromID_ToID_EXRegMUX2;    
wire[31:0] RegReadData1_FromID_To_ID_EXReg;    
wire[31:0] RegReadData2_FromID_To_ID_EXReg;    
wire[31:0] RegWriteData_FromWB_To_Reg32;    
wire[4:0] RegWrite_FromWB_To_Reg32;    
wire WriteRegControl_FromWB_To_Reg32;    
wire[4:0] ReadReg1_FromIF_IDReg_To_Reg32=Instruction_FromIF_IDReg_To_ID[19:15];    
wire[4:0] ReadReg2_FromIF_IDReg_To_Reg32=Instruction_FromIF_IDReg_To_ID[24:20];    
wire[4:0] WriteReg_FromIF_IDReg_To_Reg32=Instruction_FromIF_IDReg_To_ID[11:7];    
///////////////////////////////////////////////    译码    //////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////    译码    //////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////    译码    //////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//32个32位寄存器 //////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
Ram_Reg32 Register32(
	.clk_res(clk),            
	.ReadReg1(ReadReg1_FromIF_IDReg_To_Reg32),
	.ReadReg2(ReadReg2_FromIF_IDReg_To_Reg32),
	.WriteReg(RegWrite_FromWB_To_Reg32),//寄存器写地址
	.Writedata(RegWriteData_FromWB_To_Reg32),//寄存器写数据	
	.en_RegWrite(WriteRegControl_FromWB_To_Reg32),//寄存器写使能
	.ReadData1(RegReadData1_FromID_ToID_EXRegMUX1),
	.ReadData2(RegReadData2_FromID_ToID_EXRegMUX2)	
);
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//选择给ID_EXReg的两个寄存器DATA，解决WB ID 问题////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
wire[1:0] IDEXRegSRC1Sel_FromForwardingUnit_ToMUXIDEXRegSRC1;
wire[1:0] IDEXRegSRC2Sel_FromForwardingUnit_ToMUXIDEXRegSRC2;
mux MUXIDEXRegSRC1(
	.source1(RegReadData1_FromID_ToID_EXRegMUX1),
	.source2(0),
	.source3(ALUResultFromEX_MEMReg_To_MEM_WBReg),
	.source4(RegWriteData_FromWB_To_Reg32),
	.select(IDEXRegSRC1Sel_FromForwardingUnit_ToMUXIDEXRegSRC1),
	.result(RegReadData1_FromID_To_ID_EXReg)
);
mux MUXIDEXRegSRC2(
	.source1(RegReadData2_FromID_ToID_EXRegMUX2),
	.source2(0),
	.source3(ALUResultFromEX_MEMReg_To_MEM_WBReg),
	.source4(RegWriteData_FromWB_To_Reg32),
	.select(IDEXRegSRC2Sel_FromForwardingUnit_ToMUXIDEXRegSRC2),
	.result(RegReadData2_FromID_To_ID_EXReg)
);

wire[31:0] Imm_FromimmGen_To_IDEXReg;
///////////////////////////////////////////////////////////////////////////////
///立即数产生//////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
immGen IMMGEN(
	.Instruction(Instruction_FromIF_IDReg_To_ID),
	.imm(Imm_FromimmGen_To_IDEXReg)
); 
  
wire[31:0] NowPC_FromID_EX_Reg_To_EX;    
wire[31:0] NowPCADD4_FromID_EX_Reg_To_EX_MEMReg; 
wire  ID_EXResetFromHazardDetectionUnit_To_ID_EXReg;  
wire[31:0] Imm_FromIDEXReg_To_EX;
wire[31:0] RegReadData1_FromIDEXReg_To_EX;
wire[31:0] RegReadData2_FromIDEXReg_To_EX;
wire[4:0] ReadReg1_FromID_EXReg_To_EX;
wire[4:0] ReadReg2_FromID_EXReg_To_EX;
wire[4:0] WriteReg_FromID_EXReg_To_EX;

wire               Branch_FromID_To_ID_EXReg;
wire               MemRead_FromID_To_ID_EXReg;
wire               MemtoReg_FromID_To_ID_EXReg;
wire[2:0]          ALUOp_FromID_To_ID_EXReg;
wire               MemWrite_FromID_To_ID_EXReg;
wire               ALUSrc_FromID_To_ID_EXReg;
wire               RegWrite_FromID_To_ID_EXReg;
wire               J_FromID_To_ID_EXReg;

wire               Branch_FromID_EXReg_To_EX;
wire               MemRead_FromID_EXReg_To_ID_EXReg;
wire               MemtoReg_FromID_EXReg_To_ID_EXReg;
wire[2:0]          ALUOp_FromID_EXReg_To_EX;
wire               MemWrite_FromID_EXReg_To_ID_EXReg;
wire               ALUSrc_FromID_EXReg_To_EX;
wire               RegWrite_FromID_EXReg_To_ID_EXReg;
wire               J_FromID_EXReg_To_ID_EXReg;

wire[4:0] Func3Fun7_FromID_To_EX={Instruction_FromIF_IDReg_To_ID[30],Instruction_FromIF_IDReg_To_ID[14:12]};
wire[4:0] Func3Fun7_FromID_EXReg_ToEX;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////ID/EX缓冲///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////	
IDEXReg  IDEXReg_u(
    .clk(clk),
    .reset_n(reset_n&ID_EXResetFromHazardDetectionUnit_To_ID_EXReg),
    .en(Hit),
    .PC_FromID(NowPC_FromIF_IDReg_To_ID_EXReg), 
    .PC_ToEX(NowPC_FromID_EX_Reg_To_EX),//
    .PCAdd4_FromID(NowPCADD4_FromIF_IDReg_To_ID_EXReg), 
    .PCAdd4_ToEX(NowPCADD4_FromID_EX_Reg_To_EX_MEMReg),//
    
    .Imm_FromID(Imm_FromimmGen_To_IDEXReg), 
    .Imm_ToEX(Imm_FromIDEXReg_To_EX),//
    
    
    .RegReadData1_FromID(RegReadData1_FromID_To_ID_EXReg), 
    .RegReadData1_ToEX(RegReadData1_FromIDEXReg_To_EX),
    .RegReadData2_FromID(RegReadData2_FromID_To_ID_EXReg), 
    .RegReadData2_ToEX(RegReadData2_FromIDEXReg_To_EX),

    .RegRead1_FromID(ReadReg1_FromIF_IDReg_To_Reg32), 
    .RegRead1_ToEX(ReadReg1_FromID_EXReg_To_EX),
    .RegRead2_FromID(ReadReg2_FromIF_IDReg_To_Reg32), 
    .RegRead2_ToEX(ReadReg2_FromID_EXReg_To_EX),
    .WriteReg_FromID(WriteReg_FromIF_IDReg_To_Reg32), 
    .WriteReg_ToEX(WriteReg_FromID_EXReg_To_EX),     
  
    .Branch_FromID(Branch_FromID_To_ID_EXReg),
    .MemRead_FromID(MemRead_FromID_To_ID_EXReg),
    .MemtoReg_FromID(MemtoReg_FromID_To_ID_EXReg),
    .ALUOp_FromID(ALUOp_FromID_To_ID_EXReg),
    .MemWrite_FromID(MemWrite_FromID_To_ID_EXReg),
    .ALUSrc_FromID(ALUSrc_FromID_To_ID_EXReg),
    .RegWrite_FromID(RegWrite_FromID_To_ID_EXReg),
    .J_FromID(J_FromID_To_ID_EXReg),
    
    .Branch_ToEX(Branch_FromID_EXReg_To_EX),
    .MemRead_ToEX(MemRead_FromID_EXReg_To_ID_EXReg),
    .MemtoReg_ToEX(MemtoReg_FromID_EXReg_To_ID_EXReg),
    .ALUOp_ToEX(ALUOp_FromID_EXReg_To_EX),
    .MemWrite_ToEX(MemWrite_FromID_EXReg_To_ID_EXReg),
    .ALUSrc_ToEX(ALUSrc_FromID_EXReg_To_EX),
    .RegWrite_ToEX(RegWrite_FromID_EXReg_To_ID_EXReg),
    .J_ToEX(J_FromID_EXReg_To_ID_EXReg),
    
    .Func3Fun7_FromID(Func3Fun7_FromID_To_EX), 
    .Func3Fun7_ToEX(Func3Fun7_FromID_EXReg_ToEX)
    );
///////////////////////////////////////////////////////////////////////////////
//控制单元/////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
Control Control(
    .opcode(Instruction_FromIF_IDReg_To_ID[6:0]),
    .Branch(Branch_FromID_To_ID_EXReg),
    .MemRead(MemRead_FromID_To_ID_EXReg),
    .MemtoReg(MemtoReg_FromID_To_ID_EXReg),
    .ALUOp(ALUOp_FromID_To_ID_EXReg),
    .MemWrite(MemWrite_FromID_To_ID_EXReg),
    .ALUSrc(ALUSrc_FromID_To_ID_EXReg),
    .RegWrite(RegWrite_FromID_To_ID_EXReg),
	.jal_select(J_FromID_To_ID_EXReg)
);
///////////////////////////////////////////////    执行    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////    执行    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////    执行    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////////////////////////////////////
//  ALU ///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    
wire[31:0] ALUSource1_FromALUSourceMUX_To_ALU;      
wire[31:0] ALUSource2_FromALUSourceMUX_To_ALU;      
wire[4:0] ALUCtrl_FromALUCtrl_To_ALU;      
wire ALUZero; 

ALU ALU(
	.source1(ALUSource1_FromALUSourceMUX_To_ALU),
	.source2(ALUSource2_FromALUSourceMUX_To_ALU),
	.ALUCtrl(ALUCtrl_FromALUCtrl_To_ALU),
	.Zero(ALUZero),
	.result(ALUResult_FromALU_To_EX_MEMReg)
); 
///////////////////////////////////////////////////////////////////////////////
////ALU控制////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
ALUCtrl ALUCTRL(
		.instruction(Func3Fun7_FromID_EXReg_ToEX),
		.ALUOp(ALUOp_FromID_EXReg_To_EX),        
		.ALUCtrl(ALUCtrl_FromALUCtrl_To_ALU)
	);  
///////////////////////////////////////////////////////////////////////////////
// PC+立即数///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
wire[31:0] ImmShiftLeft1_FromShiftLeft1_ToPCADDIMM;
add32 PCADDIMM(
	.source1(NowPC_FromID_EX_Reg_To_EX),
	.source2(ImmShiftLeft1_FromShiftLeft1_ToPCADDIMM),
	.result(PCAddImm_FromEX_PCSourceMUX)
); 
///////////////////////////////////////////////////////////////////////////////
//立即数左移一位///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
shiftleft1 ShiftLeft1(
	.source1(Imm_FromIDEXReg_To_EX),
	.result(ImmShiftLeft1_FromShiftLeft1_ToPCADDIMM)
);

///////////////////////////////////////////////////////////////////////////////
//选择ALU第一个操作数来源////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

wire[1:0] ALUSrc1Ctrl_FromForwardingUnit_To_ALUSrc1;
wire[1:0] ALUSrc2Ctrl_FromForwardingUnit_To_ALUSrc2;
mux MUXALUSRC1(
	.source1(RegReadData1_FromIDEXReg_To_EX),
	.source2(32'b0),
	.source3(ALUResultFromEX_MEMReg_To_MEM_WBReg),
	.source4(RegWriteData_FromWB_To_Reg32),
	.select(ALUSrc1Ctrl_FromForwardingUnit_To_ALUSrc1),
	.result(ALUSource1_FromALUSourceMUX_To_ALU)
);

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//选择ALU第二个操作数来源////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
mux MUXALUSRC2(
	.source1(RegReadData2_FromIDEXReg_To_EX),
	.source2(Imm_FromIDEXReg_To_EX),
	.source3(ALUResultFromEX_MEMReg_To_MEM_WBReg),
	.source4(RegWriteData_FromWB_To_Reg32),
	.select(ALUSrc2Ctrl_FromForwardingUnit_To_ALUSrc2),
	.result(ALUSource2_FromALUSourceMUX_To_ALU)
);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////前递单元///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
wire[4:0] WriteReg_FromEX_MEMReg_To_MEM_WB;
wire      WriteRegEn_FromEX_MEMReg_To_MEM_WB;
wire[1:0] EXMEMRegSrc2CtrlFromForwardingUnit_To_EXMEMRegSrc2MUX;
ForwardingUnit  ForwardingUnit_u(
    .Reg32Source1_From_IDEX(ReadReg1_FromID_EXReg_To_EX),
    .Reg32Source2_From_IDEX(ReadReg2_FromID_EXReg_To_EX),
	.Reg32Source1_From_ID(ReadReg1_FromIF_IDReg_To_Reg32),
	.Reg32Source2_From_ID(ReadReg2_FromIF_IDReg_To_Reg32),
    .WriteRegEn_From_MEM(WriteRegEn_FromEX_MEMReg_To_MEM_WB),
    .WriteReg_From_MEM(WriteReg_FromEX_MEMReg_To_MEM_WB),  
    .WriteRegEn_From_WB(WriteRegControl_FromWB_To_Reg32),  
    .WriteReg_From_WB(RegWrite_FromWB_To_Reg32),   
    .ALUSrc_From_ID(ALUSrc_FromID_EXReg_To_EX), //ALU Src2来自谁 立即数/寄存器
    
    .ALUSrc1Ctrl_To_ALUSrc1(ALUSrc1Ctrl_FromForwardingUnit_To_ALUSrc1),
    .ALUSrc2Ctrl_To_ALUSrc2(ALUSrc2Ctrl_FromForwardingUnit_To_ALUSrc2),
	.IDEXRegSrc1Ctrl_To_IDEXRegSrc1MUX(IDEXRegSRC1Sel_FromForwardingUnit_ToMUXIDEXRegSRC1),//解决回写与译码冲突问题
    .IDEXRegSrc2Ctrl_To_IDEXRegSrc2MUX(IDEXRegSRC2Sel_FromForwardingUnit_ToMUXIDEXRegSRC2),//解决回写与译码冲突问题
	.EXMEMRegSrc2Ctrl_To_EXMEMRegSrc2MUX(EXMEMRegSrc2CtrlFromForwardingUnit_To_EXMEMRegSrc2MUX)//解决 SW指令问题（Src2正在MEM一级，未回写）
); 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////冒险预测单元///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

HazardDetectionUnit  HazardDetectionUnit_u(

    .PCADD4_From_EX(NowPCADD4_FromID_EX_Reg_To_EX_MEMReg),
    .ALUResult_From_EX(ALUResult_FromALU_To_EX_MEMReg),
    .PCADDimm_From_EX(PCAddImm_FromEX_PCSourceMUX), 
    .Branch_From_EX(Branch_FromID_EXReg_To_EX), //  1       1       0
    .J_From_EX(J_FromID_EXReg_To_ID_EXReg),      //  0       1       1
    .Zero_From_EX(ALUZero),   //  B指令   JAL     JALR
    
    .PCSourceMux_To_PCSourceMux(PCSourceMux_FromHazardDetectionUnit_To_PCSourceMux),//控制PC源的多路选择器 
    .JumpCtrl_To_PC(NextPCSel_FromHazardDetectionUnit_To_PC), //控制PC的信号源
    .IF_IDReset_To_IF_IDReg(IF_IDReset_FromHazardDetectionUnit_To_IF_IDReg), 
    .ID_EXReset_To_ID_EXReg(ID_EXResetFromHazardDetectionUnit_To_ID_EXReg), 
       
    .Source1_From_ID(ReadReg1_FromIF_IDReg_To_Reg32), 
    .Source2_From_ID(ReadReg2_FromIF_IDReg_To_Reg32), 
    .Rd_From_EX(WriteReg_FromID_EXReg_To_EX), 
    .MemRead_From_EX(MemRead_FromID_EXReg_To_ID_EXReg), 
    
    .PC_En_To_PC(PCEN_FromHazardDetectionUnit_To_PC),
    .IF_IDEn_To_IF_IDReg(IF_IDEn_FromHazardDetectionUnit_To_IF_IDReg)
);  
 
///////////////////////////////////////////////    访存    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////    访存    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////    访存    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////////////////////////////////////
///////////////////////////EX/MEM缓冲///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////	
wire[31:0] NowPCADD4_FromEXMEMReg_To_MEMWBReg;
wire[31:0] Data2_FromEXMEM_MUXSRC2_To_EXMEMReg;
wire MemtoReg_FromEXMEMReg_ToMEMWBReg;
wire J_FromEXMEMReg_ToMEMWBReg;
//assign Data_Mem_Address=ALUResultFromEX_MEMReg_To_MEM_WBReg;
wire MemRead_ToMEM;
wire MemWrite_ToMEM;
wire[31:0] Data_Mem_WriteData_Catch;
wire[31:0] DataMenoryOut_Catch;

EXMEMReg  EXMEMReg_u(
    .clk(clk),
    .reset_n(reset_n),
    .en(Hit),
    .PCAdd4_FromEX(NowPCADD4_FromID_EX_Reg_To_EX_MEMReg), 
    .PCAdd4_ToMEM(NowPCADD4_FromEXMEMReg_To_MEMWBReg),
    
    .ALUResult_FromEX(ALUResult_FromALU_To_EX_MEMReg), 
    .ALUResult_ToMEM(ALUResultFromEX_MEMReg_To_MEM_WBReg),
    
    .RegReadData2_FromEX(Data2_FromEXMEM_MUXSRC2_To_EXMEMReg),
    .RegReadData2_ToMEM(Data_Mem_WriteData_Catch),
    
    .WriteReg_FromEX(WriteReg_FromID_EXReg_To_EX), 
    .WriteReg_ToMEM(WriteReg_FromEX_MEMReg_To_MEM_WB),
    
    .MemRead_FromEX(MemRead_FromID_EXReg_To_ID_EXReg),
    .MemtoReg_FromEX(MemtoReg_FromID_EXReg_To_ID_EXReg),
    .MemWrite_FromEX(MemWrite_FromID_EXReg_To_ID_EXReg),
    .RegWrite_FromEX(RegWrite_FromID_EXReg_To_ID_EXReg),
    .J_FromEX(J_FromID_EXReg_To_ID_EXReg),
    
    .MemRead_ToMEM(MemRead_ToMEM),
    .MemtoReg_ToMEM(MemtoReg_FromEXMEMReg_ToMEMWBReg),
    .MemWrite_ToMEM(MemWrite_ToMEM),
    .RegWrite_ToMEM(WriteRegEn_FromEX_MEMReg_To_MEM_WB),
    .J_ToMEM(J_FromEXMEMReg_ToMEMWBReg)
    );

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//EXMEM第二个操作数来源////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
mux EXMEM_MUXSRC2(
	.source1(RegReadData2_FromIDEXReg_To_EX),
	.source2(0),
	.source3(ALUResultFromEX_MEMReg_To_MEM_WBReg),
	.source4(0),
	.select(EXMEMRegSrc2CtrlFromForwardingUnit_To_EXMEMRegSrc2MUX),
	.result(Data2_FromEXMEM_MUXSRC2_To_EXMEMReg)
);
///////////////////////////////////////////////    回写    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////    回写    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////    回写    //////////////////////////////////////////////////////////////////////////       
///////////////////////////////////////////////////////////////////////////////
///////////////////////////MEM/WB缓冲///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
wire[31:0] NowPCADD4_FromMEMWBReg_To_WBMUX;
wire[31:0] ALUResult_FromMEMWBReg_To_WBMUX;
wire[31:0] MEMReadData_FromMEMWBReg_To_WBMUX;
wire MemtoReg_FromMEMWBReg_To_WBMUX;
wire J_FromMEMWBReg_To_WBMUX;
wire Catch_To_MemWrite;
wire Catch_To_MemRead;
wire[31:0] Catch_To_Data_Mem_Address;
wire[31:0] Catch_To_Data_Mem_WriteData;

//外设访问仲裁信号
assign PCI_MEM_Ctrl =  ALUResultFromEX_MEMReg_To_MEM_WBReg[31]&(MemWrite_ToMEM|MemRead_ToMEM);//CPU进行存储器读写&&地址最高位为1
assign MemWrite =(PCI_MEM_Ctrl==0)?Catch_To_MemWrite:MemWrite_ToMEM;
assign MemRead = (PCI_MEM_Ctrl==0)?Catch_To_MemRead:MemRead_ToMEM;
assign Data_Mem_Address =(PCI_MEM_Ctrl==0)?Catch_To_Data_Mem_Address:ALUResultFromEX_MEMReg_To_MEM_WBReg;
assign Data_Mem_WriteData = (PCI_MEM_Ctrl==0)?Catch_To_Data_Mem_WriteData:Data_Mem_WriteData_Catch;
reg reg_PCI_MEM_Ctrl;//将PCI_MEM_Ctrl延时一个周期，用于在WB级控制最终的访问内存的输出
always @ (posedge clk) begin
    if(!reset_n) reg_PCI_MEM_Ctrl<='b0;
    else reg_PCI_MEM_Ctrl<=PCI_MEM_Ctrl;
end  

Cache Cache(
    .clk(clk),
    .rst_n(reset_n),
    .AddressInFromCPU(ALUResultFromEX_MEMReg_To_MEM_WBReg),//CPU读写的地址
    .DataInFromCPU(Data_Mem_WriteData_Catch),//CPU的数据，写入Catch时使用
	.DataInFromMEM(DataMenoryOut),//MEM的数据,刷新Catch时使用
    
    .en_WriteFromCPU(MemWrite_ToMEM & ~PCI_MEM_Ctrl),//写使能，CPU要读写内存，通过Catch来缓冲
    .en_ReadFromCPU(MemRead_ToMEM & ~PCI_MEM_Ctrl),//读使能，CPU要读写内存，通过Catch来缓冲
    
    .Hit(Hit),//有效位用来 表示该cache块是否有效
    .en_WriteToMEM(Catch_To_MemWrite),//读写MEM是否有效,刷新Catch时使用
    .en_ReadToMEM(Catch_To_MemRead),//读写MEM是否有效,刷新Catch时使用
	.DataOutToCPU(DataMenoryOut_Catch),//输出给CPU的数据,直接出数据，所以需要使用流水线上的寄存器
	.AddressOutToMEM(Catch_To_Data_Mem_Address),//输出给MEM的地址,刷新Catch时使用
	.DataOutToMEM(Catch_To_Data_Mem_WriteData)//输出给MEM的数据,刷新Catch时使用
    );
MEMWBReg MEMWBReg_u(
    .clk(clk),
    .reset_n(reset_n),
    .en(1),
    .PCAdd4_FromMEM(NowPCADD4_FromEXMEMReg_To_MEMWBReg), 
    .PCAdd4_ToWB(NowPCADD4_FromMEMWBReg_To_WBMUX),
    
    .ALUResult_FromMEM(ALUResultFromEX_MEMReg_To_MEM_WBReg), 
    .ALUResult_ToWB(ALUResult_FromMEMWBReg_To_WBMUX),
    
    .MEMReadData_FromMEM(DataMenoryOut_Catch), 
    .MEMReadData_ToWB(MEMReadData_FromMEMWBReg_To_WBMUX),
    
    .WriteReg_FromMEM(WriteReg_FromEX_MEMReg_To_MEM_WB), 
    .WriteReg_ToWB(RegWrite_FromWB_To_Reg32),
    
    .MemtoReg_FromMEM(MemtoReg_FromEXMEMReg_ToMEMWBReg),
    .RegWrite_FromMEM(WriteRegEn_FromEX_MEMReg_To_MEM_WB),
    .J_FromMEM(J_FromEXMEMReg_ToMEMWBReg),
    
    .MemtoReg_ToWB(MemtoReg_FromMEMWBReg_To_WBMUX),
    .RegWrite_ToWB(WriteRegControl_FromWB_To_Reg32),
    .J_ToWB(J_FromMEMWBReg_To_WBMUX)
    );
///////////////////////////////////////////////////////////////////////////////
//选择写寄存器操作数来源////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//回写的数据来自于  存储器(Catch数据) 还是 来自外设，外设直接穿透 MEM寄存器组，因为外设的访存在给地址后下个周期才输出数据
wire[31:0] MEM_OR_PCI_Data_To_WBMUX = (reg_PCI_MEM_Ctrl == 0)?MEMReadData_FromMEMWBReg_To_WBMUX:DataMenoryOut;

mux WBMUX(
	.source1(ALUResult_FromMEMWBReg_To_WBMUX),
	.source2(MEM_OR_PCI_Data_To_WBMUX),
	.source3(NowPCADD4_FromMEMWBReg_To_WBMUX),
	.source4(NowPCADD4_FromMEMWBReg_To_WBMUX),
	.select({J_FromMEMWBReg_To_WBMUX,MemtoReg_FromMEMWBReg_To_WBMUX}),
	.result(RegWriteData_FromWB_To_Reg32)
);


endmodule