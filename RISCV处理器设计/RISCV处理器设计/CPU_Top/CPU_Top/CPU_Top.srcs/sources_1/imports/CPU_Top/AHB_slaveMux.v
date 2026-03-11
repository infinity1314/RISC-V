module AHB_slaveMux #(
		parameter  AW = 16,//从机地址总线宽度(选中从机后，从机只取地址的低位作为从机器件的操作地址)
                 DW = 32,//从机数据总线宽度,这里不打算改了，就用32�?
					  UART_BSP_RATE = 115200,//波特�?
					  CLK_PERIORD = 20
)(	
			input 				clk,
			input 				rst_n,
			input  	wire[31:0]			addr,
			input				HSEL,
			input	wire		Read_Write,		//0锛氳〃绀鸿鍙栵�?1锛氳〃绀哄啓鏁版�?
			input	wire[31:0]	H_WriteData,		
			input  wire [1:0]   HTRANS,   		//渚嬪寲鏃剁洿鎺ヨ涓1
			input  wire [2:0]   HSIZE, 			//渚嬪寲鏃剁洿鎺ヨ涓11
			input  wire [3:0]   HPROT,     		//渚嬪寲鏃剁洿鎺ヨ涓111
			input  wire [2:0] 	HBURST,			//渚嬪寲鏃剁洿鎺ヨ涓11		

			
			output		[31:0]	S_ReadData,		//浠庢�?涓鍙栧嚭鐨勬暟鎹		
			output 	wire		HREADYOUT,
			output	wire		HRESP,			//浠庢�?搴旂瓟鍒ゅ喅	



//////////////////澶栬鎺ュ彛/////////////////////////////
			input   wire  	[7:0]    Key_press,
			output  wire	[7:0]   led,
			output	wire	[6:0] 	hex_0,
			output	wire	[6:0] 	hex_1,
			output	wire	[6:0] 	hex_2,
			output	wire	[6:0] 	hex_3,
			output	wire	[3:0]	hex_dp,
			input  i_rx_pin,
			output o_tx_pin
);


wire 	HRESP_mux;//搴旂瓟淇″彿鍒ゅ喅缁撴灉
assign 	HRESP = HRESP_mux;
reg [31:0] HRDATA_mux;//鍒ゅ喅缁撴灉
assign S_ReadData = HRDATA_mux;
assign HREADYOUT = HREADY_mux;



	
reg	[7:0]H_sel;
always@(addr)
	begin
	H_sel=8'h0;
	if(HSEL==1)begin
		case(addr[31:28])
			4'h8:begin
				case(addr[27:24])
				4'h0:H_sel=8'b0000_0001;		//閫変腑涓簂ed
				4'h1:H_sel=8'b0000_0010;		//閫変腑uart
				4'h2:H_sel=8'b0000_0100;		//閫変腑鏁扮爜�?
				4'h3:H_sel=8'b0000_1000;		//閫変腑鎸夐敭
				4'h4:H_sel=8'b0001_0000;		//閫変腑�?�氭椂鍣
			 default:H_sel=8'b0000_0000;
			 endcase
			end
			default:H_sel=8'h0;
		endcase
		end
		
	end
	
	
reg [7:0]	sel;
//缁欑墖閫変俊鍙峰姞涓婁竴涓欢鏃
always@(posedge clk)
	begin
		if(!rst_n) sel<=8'd0;
		else begin 
			if(HREADY_mux==1) sel<=H_sel;
		end
	end
	////////////////////////////////////////
//8涓櫒浠剁殑 HREADYOUT 杈撳嚭淇″彿
////////////////////////////////////////
wire HREADYOUT0;
wire HREADYOUT1;
wire HREADYOUT2;
wire HREADYOUT3;
wire HREADYOUT4;
wire HREADYOUT5;
wire HREADYOUT6;
wire HREADYOUT7;

////////////////////////////////////////
//8涓櫒浠剁殑 HRESP 杈撳嚭淇″彿
////////////////////////////////////////
wire HRESP0;
wire HRESP1;
wire HRESP2;
wire HRESP3;
wire HRESP4;
wire HRESP5;
wire HRESP6;
wire HRESP7;
////////////////////////////////////////
//浜х敓 HREADY_mux 淇�?�彿//鍒ゅ喅缁撴灉
////////////////////////////////////////
assign  HREADY_mux = (sel[0] & HREADYOUT0) |
					 (sel[1] & HREADYOUT1) |
					 (sel[2] & HREADYOUT2) |
					 (sel[3] & HREADYOUT3) |
					 (sel[4] & HREADYOUT4) |
					 (sel[5] & HREADYOUT5) |
					 (sel[6] & HREADYOUT6) |
					 (sel[7] & HREADYOUT7) |
					 //杩欎釜鎴栭潪鏄弬鑰冨畼鏂圭殑锛屽彲鑳芥槸娌℃湁鍣ㄤ欢閫変腑鐨勬椂鍊欑洿鎺ュ氨缁
					 (!(sel[0]|sel[1]|sel[2]|sel[3]|sel[4]|sel[5]|sel[6]|sel[7]));
 

////////////////////////////////////////
//浜х敓 HRESP_mux //鍒ゅ喅缁撴灉
////////////////////////////////////////
assign  HRESP_mux =  (sel[0] & HRESP0) |
					 (sel[1] & HRESP1) |
					 (sel[2] & HRESP2) |
					 (sel[3] & HRESP3) |
					 (sel[4] & HRESP4) |
					 (sel[5] & HRESP5) |
					 (sel[6] & HRESP6) |
					 (sel[7] & HRESP7) |
					 //杩欎釜鎴栭潪鏄弬鑰冨畼鏂圭殑锛屽彲鑳芥槸娌℃湁鍣ㄤ欢閫変腑鐨勬椂鍊欑洿鎺ュ氨缁
					 (!(sel[0]|sel[1]|sel[2]|sel[3]|sel[4]|sel[5]|sel[6]|sel[7])); 

////////////////////////////////////////
//浜х敓 HRDATA_mux //鍒ゅ喅缁撴灉
////////////////////////////////////////
wire [31:0] HRDATA0;
wire [31:0] HRDATA1;
wire [31:0] HRDATA2;
wire [31:0] HRDATA3;
wire [31:0] HRDATA4;
always @ (*) begin
	case(sel)
		8'b0000_0001: HRDATA_mux = HRDATA0;
		8'b0000_0010: HRDATA_mux = HRDATA1;
		8'b0000_0100: HRDATA_mux = HRDATA2;
		8'b0000_1000: HRDATA_mux = HRDATA3;
		8'b0001_0000: HRDATA_mux = HRDATA4;
		default: HRDATA_mux = 32'h0000_0000;
	endcase
end


AHB_led		AHB_led_inst(

			.HCLK(clk),
			.HRESETn(rst_n),  
			.HSEL(H_sel[0]), 
			.HBURST(HBURST),
			.HADDR(addr), 
			.HTRANS(HTRANS),   
			.HSIZE(HSIZE), 
			.HPROT(HPROT),    
			.HWRITE(Read_Write),   
			.HREADY(1'b1),   
			.HWDATA(H_WriteData),   
			.HREADYOUT(HREADYOUT0),
			.HRDATA(HRDATA0),   
			.HRESP(HRESP0),
			.led(led)

);
AHB_UART		#(
			.UART_BSP_RATE(UART_BSP_RATE),
			.CLK_PERIORD(CLK_PERIORD)
	 )AHB_UART_inst(
			.HCLK(clk),
			.HRESETn(rst_n),  
			.HSEL(H_sel[1]), 
			.HBURST(HBURST),
			.HADDR(addr), 
			.HTRANS(HTRANS),   
			.HSIZE(HSIZE), 
			.HPROT(HPROT),    
			.HWRITE(Read_Write),   
			.HREADY(1'b1),   
			.HWDATA(H_WriteData), 
	
	
			.HREADYOUT(HREADYOUT1),
			.HRDATA(HRDATA1),   
			.HRESP(HRESP1),
			
			.i_rx_pin(i_rx_pin),
			.o_tx_pin(o_tx_pin)


);
AHB_hex		AHB_hex_inst(
			.HCLK(clk),
			.HRESETn(rst_n),  
			.HSEL(H_sel[2]), 
			.HBURST(HBURST),
			.HADDR(addr), 
			.HTRANS(HTRANS),   
			.HSIZE(HSIZE), 
			.HPROT(HPROT),    
			.HWRITE(Read_Write),   
			.HREADY(1'b1),   
			.HWDATA(H_WriteData),   
			.HREADYOUT(HREADYOUT2),
			.HRDATA(HRDATA2),   
			.HRESP(HRESP2),
			.hex_0(hex_0),
			.hex_1(hex_1),
			.hex_2(hex_2),
			.hex_3(hex_3),
			.hex_dp(hex_dp)

);

AHB_key		AHB_key_inst(

	
			.HCLK(clk),
			.HRESETn(rst_n),  
			.HSEL(H_sel[3]), 
			.HBURST(HBURST),
			.HADDR(addr), 
			.HTRANS(HTRANS),   
			.HSIZE(HSIZE), 
			.HPROT(HPROT),    
			.HWRITE(Read_Write),   
			.HREADY(1'b1),   
			.HWDATA(H_WriteData),   
			.HREADYOUT(HREADYOUT3),
			.HRDATA(HRDATA3),   
			.HRESP(HRESP3),    
			.Key_press(Key_press) 

);
AHB_TIMER		AHB_TIMER_inst(

			.HCLK(clk),
			.HRESETn(rst_n),  
			.HSEL(H_sel[4]), 
			.HBURST(HBURST),
			.HADDR(addr), 
			.HTRANS(HTRANS),   
			.HSIZE(HSIZE), 
			.HPROT(HPROT),    
			.HWRITE(Read_Write),   
			.HREADY(1'b1),   
			.HWDATA(H_WriteData),   
			.HREADYOUT(HREADYOUT4),
			.HRDATA(HRDATA4),   
			.HRESP(HRESP4)

);

endmodule
