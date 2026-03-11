`timescale 1ns / 1ps
//一张表的一块内容
module Cacheblock #(
    parameter OffsetWide = 2,//偏移量位宽
    parameter DataWide = 32,//数据位宽
    parameter AddressWide = 32,//地址位宽
    parameter TagWide = 28//目标宽度 地址位宽-偏移量位宽-Set位宽
    )(
    input 	clk,
    input 	rst_n,
    input 	Flush,//Catch块刷新，高电平有效
    input[TagWide-1:0] 	Tag_in ,//Catch块刷新目标
    input[DataWide-1:0]  DataIn,//数据输入
    input[OffsetWide-1:0] 	Offset ,//Offset
    
    input   en_Write,//写使能
    input   en_Read,//读使能
    
    output reg[TagWide-1:0]   Tag_out ,//Catch块刷新目标
    output[DataWide-1:0]  DataOut,//数据输出
    output reg  Modify,//被修改
    output reg  V//有效位用来 表示该cache块是否有效
    );
reg   r_Flush;
wire   neg_Flush=r_Flush & !Flush;//检测Flush下降沿,立刻检测
wire   pose_Flush=!r_Flush & Flush;//检测Flush上升沿,立刻检测
always @ (posedge clk)  begin
    if(!rst_n)
        r_Flush<='b0;
    else 
       r_Flush<=Flush;
end
always @ (*)  begin
    if(!rst_n) begin
        V =0;
    end
    else begin
        if(neg_Flush) V = 1'b1;
        if(pose_Flush) V = 'b0;
    end
end

reg[DataWide-1:0] DataMem[2**OffsetWide-1:0];
integer i;
always @ (posedge clk)  begin//写入数据
    if(!rst_n)begin
        for(i=0;i<2**OffsetWide;i = i+1)
            DataMem[i]=0;
    end
    else begin
        if(en_Write) DataMem[Offset]<=DataIn;
    end
end
always @ (posedge clk)  begin//写入数据
    if(!rst_n)begin
        Modify<='b0;
        Tag_out<='b0;
    end
    else begin
        if(Flush)begin  
            Modify<='b0;
            Tag_out<=Tag_in;
        end
        if(!Flush && en_Write) Modify<='b1;//非刷新时写入置1
    end
end
assign DataOut = (en_Read==1)?DataMem[Offset]:32'b0;//输出数据，未选择时为0，选中输出结果

endmodule
