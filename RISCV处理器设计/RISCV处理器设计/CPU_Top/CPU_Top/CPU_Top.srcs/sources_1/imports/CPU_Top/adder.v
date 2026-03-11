module adder(a,b,ci_1,si,ci);//È«¼ÓÆ÷
	input a,b,ci_1;
	output si,ci;
	
	wire s1,m1,m2,m3,m4;
	
	xor(s1,a,b);//s1=a^b
	xor(si,s1,ci_1);//si=s1^ci_1=a^b^ci_1
	and(m1,a,b);//m1=a&b
	and(m2,a,ci_1);//m2=a&ci_1
	and(m3,b,ci_1);//m3=b&ci_1
	or(m4,m3,m2);//m4=m3+m2
	or(ci,m1,m4);//ci=m1+m4=m1+m3+m2= a&b + a&ci_1 + b&ci_1
	
 
 
endmodule 