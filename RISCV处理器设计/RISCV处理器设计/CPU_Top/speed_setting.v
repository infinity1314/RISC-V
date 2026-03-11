`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/22 21:44:08
// Design Name: 
// Module Name: speed_setting
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module speed_setting    #(
    parameter UART_BSP_RATE = 115200,
    parameter   CLK_PERIORD = 20
)
(
    input i_clk,
    input i_rst_n,
    input i_bps_en,
    output reg o_bps_start//一个周期的起始输出高电平，中间做一次反转
    );

localparam BPS_CNT_MAX = 1000_000_000/UART_BSP_RATE/CLK_PERIORD - 1;    
localparam BPS_CNT_HALF = BPS_CNT_MAX/2 - 1;    

reg[15:0] r_bps_cnt;

/////////////////////////////////////////////////////////////////
//波特率分频计数
always @ (posedge i_clk)
    if(!i_rst_n) r_bps_cnt<=0;
    else if(i_bps_en)begin
        if(r_bps_cnt < BPS_CNT_MAX) r_bps_cnt<=r_bps_cnt+1;
        else    r_bps_cnt<=0;
    end
    else r_bps_cnt<=0;

////////////////////////////////////////////////////////////////////////////////
//产生 o_bps_start 信号   
always @ (posedge i_clk)
    if(!i_bps_en)o_bps_start<=0;
    else if(r_bps_cnt < BPS_CNT_HALF) o_bps_start<=1;
    else o_bps_start<=0;    
    
endmodule
