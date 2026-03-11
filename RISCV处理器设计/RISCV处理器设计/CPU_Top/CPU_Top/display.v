module display(sw,key_confirm_1,key_confirm_2,led);//main
	input [3:0]sw;
	input key_confirm_1,key_confirm_2;
	output [3:0]led;
 
	reg [3:0]a;
	reg [3:0]b;
	
	wire ci,cout;
	
		always@(*)begin
		if (key_confirm_1==0)begin									//1号确认键确认被加数
		a=sw;
		end
		else if(key_confirm_2==0)begin                              //2号确认键确认加数
		b=sw;
		end
	end
	my_4adder u5(.a(a),.b(b),.s(led),.ci(ci),.cout(cout));
	
endmodule 