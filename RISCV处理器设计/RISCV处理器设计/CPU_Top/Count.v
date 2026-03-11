`timescale 1ns / 1ps

module Count #(
    parameter CountWide = 8,//计数位宽
    parameter CountMax = 255//计数最大值
    )(
    input 	clk,
    input 	rst_n,
    input 	Clear,//清零
    input 	En,//清零
    output reg[CountWide-1:0] 	CountOut //Catch块刷新目标
    );
always @ (posedge clk)  begin
    if(!rst_n) 
        CountOut<='b0;
    else if(Clear) CountOut<='b0;
    else if(En)begin
        if(CountOut<CountMax) CountOut<=CountOut+1'b1;
        else CountOut<=CountOut;
    end
    else CountOut<=CountOut;
end
       
endmodule
