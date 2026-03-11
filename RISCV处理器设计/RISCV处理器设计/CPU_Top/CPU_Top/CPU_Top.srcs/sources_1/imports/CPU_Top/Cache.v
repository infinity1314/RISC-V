`timescale 1ns / 1ps
//https://blog.csdn.net/cxy_hust/article/details/112305530
module Cache #(
    parameter OffsetWide = 2,//偏移量位宽
    parameter DataWide = 32,//数据位宽
    parameter AddressWide = 32,//地址位宽
    parameter TagWide = 28,//目标宽度 地址位宽-偏移量位宽-Set位宽
    parameter SetWide = 2,//路组位宽度
    parameter WayNum = 2,//路径个数 = 2^(路径位宽)
    parameter WayWide = 1,//路径位宽
    parameter CountWide = 8,//计数位宽
    parameter CountMax = 255//计数最大值
    )(
    input 	clk,
    input 	rst_n,
    input[AddressWide-1:0]  AddressInFromCPU,//CPU读写的地址
    input[DataWide-1:0]  DataInFromCPU,//CPU的数据，写入Catch时使用
	input[DataWide-1:0]  DataInFromMEM,//MEM的数据,刷新Catch时使用
    
    input   en_WriteFromCPU,//写使能
    input   en_ReadFromCPU,//读使能
    
    output Hit,//有效位用来 表示该cache块是否有效
    output reg  en_WriteToMEM,//读写MEM是否有效,刷新Catch时使用
    output reg  en_ReadToMEM,//读写MEM是否有效,刷新Catch时使用
	output [DataWide-1:0]  DataOutToCPU,//输出给CPU的数据
	output reg[AddressWide-1:0]  AddressOutToMEM,//输出给MEM的地址,刷新Catch时使用
	output [DataWide-1:0]  DataOutToMEM//输出给MEM的数据,刷新Catch时使用
    );
localparam Setend =  (SetWide+OffsetWide-1);  
localparam Tagend =  (SetWide+OffsetWide);
wire[(2**SetWide)*WayNum-1:0] Set_en_Read;////所有路径的 读使能
wire[(2**SetWide)*WayNum-1:0] Set_en_Write;////所有路径的 写使能
reg[(2**SetWide)*WayNum-1:0] Set_Flush;////所有路径的 Catch块刷新
wire[DataWide-1:0] Set_DataIn;//数据输入
wire[OffsetWide-1:0] Set_Offset;
wire[TagWide-1:0] Set_Tag_in = AddressInFromCPU[AddressWide-1:Tagend];//Catch块刷新目标

wire[TagWide-1:0] Set_Tag_out[(2**SetWide)*WayNum-1:0];//Catch块存放Tag的输出
wire[(2**SetWide)*WayNum-1:0] Set_V;////所有路径的 有效位
wire[(2**SetWide)*WayNum-1:0] Set_Modify;////所有路径的 是否被修改
wire[DataWide-1:0]  Set_DataOut[(2**SetWide)*WayNum-1:0];////所有路径的 数据输出
wire[CountWide-1:0] 	SetCount[(2**SetWide)*WayNum-1:0];//记录所有路径的使用情况
wire[SetWide-1:0] Now_Set=AddressInFromCPU[Setend:OffsetWide];//当前选中的路组号
wire[(2**SetWide)-1:0] SetMAXCount;//Set 最大计数的位置（将被置换）
localparam //IDLE =0,
           Ready=1,//就绪
           UNReady=2,//未就绪
           WriteBack=3,//回写数据
           ReadData=4,//读取数据
           RDdalay=5;//读取数据
reg[3:0] state;//状态切换
reg[OffsetWide:0] Set_Flush_Count;//刷新Catch时的计数器,比实际位宽要大1，否则可能有问题
wire[SetWide+WayWide-1:0] RowNumber = {Now_Set,1'b0}+SetMAXCount[Now_Set];//被替换的行号
reg [SetWide+WayWide-1:0] reg_RowNumber;//RowNumber需要寄存
reg [OffsetWide:0] dec_Flush_Count;//上一个_Flush_Count的值，在读写数据的时钟问题
reg [OffsetWide:0] dec_Flush_Count1;//在读取MEM数据时延时一个周期将Flush_Count给dec_Flush_Count，在写数据的时钟问题（三时钟周期）
integer k;
always @ (posedge clk)  begin
    if(!rst_n) begin
        state <=Ready;
        en_WriteToMEM<=0;
        en_ReadToMEM<=0;
        dec_Flush_Count<=0;
        for(k=0;k<(2**SetWide)*WayNum;k=k+1)
            Set_Flush[k]<=0;
    end
    else begin
        case(state)
            Ready:begin//就绪
                if(en_WriteFromCPU||en_ReadFromCPU)begin
                    if(Hit == 1) state <=Ready;
                    else begin
						state <=UNReady;//未命中
						Set_Flush_Count<=0;
						reg_RowNumber<=RowNumber;
					end
                end
                else begin
                    state <=Ready;
                end
            end
            UNReady:begin//未就绪
                if(Set_Modify[reg_RowNumber] == 1) state <=WriteBack;//数据被修改过，要写会
                else begin
                    state <=ReadData;//数据未被修改过，直接刷新
                end
                Set_Flush_Count<=0;
            end
            WriteBack:begin//回写数据
                if(Set_Flush_Count<(2**OffsetWide))begin
                    AddressOutToMEM<={Set_Tag_out[reg_RowNumber],Now_Set,Set_Flush_Count[OffsetWide-1:0]}; 
                    dec_Flush_Count<=Set_Flush_Count;
                    
                    en_WriteToMEM<=1;
                    Set_Flush_Count<=Set_Flush_Count+1'b1;
                end
                else begin
                    Set_Flush_Count<=0;
                    en_WriteToMEM<=0;
                    state <=ReadData;//刷新Catch                    
                end                
            end
            ReadData:begin//读取数据
                if(Set_Flush_Count<(2**OffsetWide))begin
                    Set_Flush[reg_RowNumber]<=1;
                    AddressOutToMEM<={AddressInFromCPU[AddressWide-1:OffsetWide],Set_Flush_Count[OffsetWide-1:0]};
                    dec_Flush_Count<=dec_Flush_Count1;
                    dec_Flush_Count1<=Set_Flush_Count;
                    en_ReadToMEM<=1;
                    Set_Flush_Count<=Set_Flush_Count+1'b1;
                end
                else begin
                    Set_Flush[reg_RowNumber]<=0;
                    en_ReadToMEM<=0;
                    state <= RDdalay;
                end
            end
			RDdalay:begin//读取数据后延时缓冲，等待数据写入成功
                    state <= Ready;
            end
            default: state <= Ready;
        endcase
    end
end
assign DataOutToMEM =Set_DataOut[reg_RowNumber];
assign Set_DataIn =(state ==Ready)? DataInFromCPU : DataInFromMEM;
assign Set_Offset =(state ==Ready)? AddressInFromCPU[OffsetWide-1:0]:dec_Flush_Count[OffsetWide-1:0];

wire[WayNum-1:0] Hitx;//路组是否命中，多路比较复杂

wire[WayNum-1:0] Equal_Tag;//选中路组是否与目标相等
reg[TagWide-1:0] Hit_Set_Tag[WayNum-1:0];//选中路组的Tag
reg[WayNum-1:0] Hit_Set_V;////选中路组的 有效位
assign Hit = ((!(Hitx == 'b0))&&(state ==Ready))||((!(en_WriteFromCPU||en_ReadFromCPU))&&(state ==Ready));//最终命中结果
genvar j;
// Generate for loop to instantiate N times
generate//将选中的Set块取出
    for (j = 0;j < WayNum; j = j + 1) begin :getset
        always @(*)begin
            Hit_Set_Tag[j] <=Set_Tag_out[{AddressInFromCPU[Setend:OffsetWide],1'b0}+j];
        end
        always @(*)begin
            Hit_Set_V[j] <=Set_V[{AddressInFromCPU[Setend:OffsetWide],1'b0}+j];
        end
        //比较结果是否相等
        assign Equal_Tag[j] = (Hit_Set_Tag[j]==AddressInFromCPU[AddressWide-1:Tagend]);
        //结果命中且数据有效
        assign Hitx[j] = (Equal_Tag[j]&&Hit_Set_V[j]);
    end
endgenerate

genvar i;
generate///Set 最大计数的位置（将被置换）,这里写的是两路组的，多路的不好写
    for (i = 0; i < 2**SetWide; i = i + 1) begin :getmaxcount
        assign SetMAXCount[i]=(SetCount[i*2]>SetCount[i*2+1])?1'b0:1'b1;
    end
endgenerate
// Generate for loop to instantiate N times
generate//例化Catch表
    for (i = 0; i < (2**SetWide)*WayNum; i = i + 1) begin :setCatch
        Cacheblock u0(
        .clk(clk),
        .rst_n(rst_n),
        .Flush(Set_Flush[i]),//Catch块刷新，高电平有效
        .Tag_in(Set_Tag_in),//Catch块刷新目标
        .DataIn(Set_DataIn),//数据输入
        .Offset(Set_Offset),//Offset
        
        .en_Write(Set_en_Write[i]),//写使能
        .en_Read(Set_en_Read[i]),//读使能
        .Tag_out(Set_Tag_out[i]),//Catch块
        .DataOut(Set_DataOut[i]),//数据输出
        .Modify(Set_Modify[i]),//被修改
        .V(Set_V[i])//有效位用来 表示该cache块是否有效
        );
        Count count(
        .clk(clk),
        .rst_n(rst_n),
        .Clear((i[SetWide:WayWide]==Now_Set) && Hitx[i[WayWide-1:0]]),//清零，路组号对应 & 当前的Hit命中 
        .En(en_WriteFromCPU||en_ReadFromCPU),//清零
        .CountOut(SetCount[i]) //Catch块刷新目标
        );
        assign Set_en_Read[i]=1;//直接读使能
        assign Set_en_Write[i] = ((i[SetWide:WayWide]==Now_Set) && Hitx[i[WayWide-1:0]])?en_WriteFromCPU:
                                 (state ==Ready)?1'b0:(state == ReadData&&RowNumber == i);//路组号对应 & 当前的Hit命中则将CPU写使能传递，
                                 //否则在就绪状态则赋值0，如果在ReadData状态且选中的替换行为本行则进行写操作
    end
endgenerate
assign DataOutToCPU = (Hitx[0]==1)?Set_DataOut[{Now_Set,1'b0}]:Set_DataOut[{Now_Set,1'b1}];//按照两路组写对应
endmodule
