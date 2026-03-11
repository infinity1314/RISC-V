module ALUCtrl (
            input     [3:0]  instruction,
            input     [2:0]  ALUOp,        
            output  reg  [4:0]  ALUCtrl
        );   

always @(*)
begin    
	case(ALUOp) 
	3'b010 : begin                               //R-type
		         case(instruction[3:0])
				     4'b0000 : ALUCtrl = 5'b00100;//add
				     4'b1000 : ALUCtrl = 5'b00101;//sub
				     4'b0001 : ALUCtrl = 5'b01100;//sll
				     4'b0010 : ALUCtrl = 5'b10100;//slt
				     4'b0011 : ALUCtrl = 5'b10000;//sltu
				     4'b0100 : ALUCtrl = 5'b11110;//xor
				     4'b0101 : ALUCtrl = 5'b01101;//srl
				     4'b1101 : ALUCtrl = 5'b01110;//sra
				     4'b0110 : ALUCtrl = 5'b11101;//or
				     4'b0111 : ALUCtrl = 5'b11100;//and
					 default : ALUCtrl = 5'b00000;//空操作
		         endcase
			 end
	3'b001 : begin                               //  B-type                           
			     case(instruction[2:0])
			         3'b000 : ALUCtrl = 5'b00101;//beq
			         3'b001 : ALUCtrl = 5'b00111;//bne
			         3'b100 : ALUCtrl = 5'b10100;//blt
			         3'b101 : ALUCtrl = 5'b10101;//bge
			         3'b110 : ALUCtrl = 5'b10000;//bltu
			         3'b111 : ALUCtrl = 5'b10001;//bgeu
					  3'b010 : ALUCtrl = 5'b00100;//sw
					 default: ALUCtrl = 5'b00000;//空操作
			     endcase
		     end
	3'b011 : begin                               //I-type
		         case(instruction[2:0])
				     3'b000 : ALUCtrl = 5'b00100;//addi
				     3'b010 : ALUCtrl = 5'b10100;//slti
				     3'b011 : ALUCtrl = 5'b10000;//sltiu
				     3'b100 : ALUCtrl = 5'b11110;//xori
				     3'b110 : ALUCtrl = 5'b11101;//ori
				     3'b111 : ALUCtrl = 5'b11100;//andi
				     3'b001 : ALUCtrl = 5'b01100;//slli
				     3'b101 : begin 
					              case(instruction[3]) 
								      1'b0 : ALUCtrl = 5'b01101;//srli
								      1'b1 : ALUCtrl = 5'b01110;//srai
								      default : ALUCtrl = 5'b00000;//空操作
				                  endcase
							  end
	                 default: ALUCtrl = 5'b00000;//空操作
			     endcase
			 end
	3'b100 : begin                               //I-type
		         case(instruction[2:0])
				     3'b010 : ALUCtrl = 5'b00100;//lw
				     3'b000 : ALUCtrl = 5'b00100;//jalr
			     endcase
			 end
	/* 3'b001 : begin                               //S-type
	             case(instruction[2:0])sim:/TestCPU
				    
					 default : ALUCtrl = 5'b00000;//空操作
				 endcase
			 end	 */
    3'b101 : ALUCtrl = 5'b01111;//U-type/lui
    3'b110 : ALUCtrl = 5'b00110;//J-type/jal	
	default: ALUCtrl = 5'b00000;//空操作
	endcase
end
endmodule

	