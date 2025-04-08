module train_game_logic(
    input logic clk,               // Clock signal
    input logic reset,             // Reset signal
    input logic [9:0] y,   // Row of the current pixel (from VGA_SYNC)
    input logic [9:0] x, // Column of the current pixel (from VGA_SYNC)
	 input logic sentido,
	 output logic color_out,
	 output logic s1,s2,s3,s4
);

	 //posição da pista
	  localparam PISTAH_WIDTH = 580;
	  localparam PISTAH_HEIGHT = 8;
	  localparam PISTAV_WIDTH = 8;
	  localparam PISTAV_HEIGHT = 420;
	  localparam TREM_HEIGHT = 16;
	  localparam TREM_WIDTH = 32;
	  logic conda, condb;
	  //logic s1, s2, s3, s4 = 0;
	  
	  //resolução 640x480
	 
	 always @(posedge clk or posedge reset)
	 if (reset) begin
			s1 = 0;
			s2 = 0;
			s3 = 1;
			s4 = 1;
	
	  end else begin
			conda = !(x >= ptxa && x < ptxa + TREM_WIDTH && y >= ptya && y < ptya + TREM_HEIGHT);
			condb = !(x >= ptxb && x < ptxb + TREM_WIDTH && y >= ptyb && y < ptyb + TREM_HEIGHT);
			color_out = 1'b0;
			
			if (ptxa == 60 && ptya == 300 )
			begin
				s4 = 0;
				s1 = 1;
			end else begin
			s4 = s4;
			s1 = s1;
			end
	
			
			if (ptxb == 120 && ptyb == 300 )
			begin
				s3 = 0;
				s2 = 1;
			end else begin
			 s3 = s3;
			 s2 = s2;
			 end
			
			if (ptxb == 520 && ptyb == 300 )
			begin
				s2 = 0;
				s3 = 1;
			end else begin
			 s2 = s2;
			 s3 = s3;
			end
			
			if (ptxa == 580 && ptya == 300 )
			begin
				s1 = 0;
				s4 = 1;
			end else begin
			s4 = s4;
			s1 = s1;
			end
				
			
				
			
			
			//barras horizontais maiores
			if(y == 60 && x <= PISTAH_WIDTH && x >= 60 && conda )
				color_out = 1'b1;	
				
			if(y == 420 && x <= PISTAH_WIDTH && x >= 60 && conda && condb)
				color_out = 1'b1;	
				
			//barras verticais maiores
			if(x == 60 && y <= PISTAV_HEIGHT && y >= 60 && conda)
				color_out = 1'b1;	
				
			if(x == 580 && y <= PISTAV_HEIGHT && y >= 60 && conda)
				color_out = 1'b1;	
				
			//barra horizontal menor	
			if(y == 180 && x <= PISTAH_WIDTH-60 && x >= 120 && condb)
				color_out = 1'b1;	
				
			//barras verticais menores
			if(x == 120 && y <= PISTAV_HEIGHT && y >= 180 && condb)
				color_out = 1'b1;
				
			if(x == PISTAH_WIDTH-60 && y <= PISTAV_HEIGHT && y >= 180 && condb) 
				color_out = 1'b1;	
				
			//desenho do trem A
			if(!conda)begin
				if(trainA[y-ptya][TREM_WIDTH - (x-ptxa) - 1])
					color_out = 1'b1;
				end	
				
			//desenho do trem B
			if(!condb)begin
				if(trainB[y-ptyb][TREM_WIDTH - (x-ptxb) ])
					color_out = 1'b1;
				end		
		
		end		
	 
	 reg [31:0] trainA [0:15];
	 reg [31:0] trainB [0:15]; 

initial begin
    s1 = 0;
    s2 = 0;
    s3 = 1;
    s4 = 1;
end
initial begin 
    trainA[0]  = 32'b11111111111111111111111111111111;
    trainA[1]  = 32'b11111111111111111111111111111111;
    trainA[2]  = 32'b11111111111110000000111111111111;
    trainA[3]  = 32'b11111111111110000000111111111111;
    trainA[4]  = 32'b11111111000000001100000001111111;
    trainA[5]  = 32'b11111111000000011100000001111111;
    trainA[6]  = 32'b11100000001111111111111000000011;
    trainA[7]  = 32'b11100000001111111111111000000011;
    trainA[8]  = 32'b11100000001111111111111000000011;
    trainA[9]  = 32'b11100000000000000000000000000011;
    trainA[10] = 32'b11100000000000000000000000000011;
    trainA[11] = 32'b11100000001111111111111000000011;
    trainA[12] = 32'b11100000001111111111111000000011;
    trainA[13] = 32'b11100000001111111111111000000011;
    trainA[14] = 32'b11111111111111111111111111111111;
    trainA[15] = 32'b11111111111111111111111111111111;
end

initial begin
    trainB[0]  = 32'b11111111111111111111111111111111;
    trainB[1]  = 32'b11111000000000000000000000111111;
    trainB[2]  = 32'b11111000000000000000000000111111;
    trainB[3]  = 32'b10000001111111111110000000111111;
    trainB[4]  = 32'b00000001111111111110000000111111;
    trainB[5]  = 32'b00000001111111111110000000111111;
    trainB[6]  = 32'b00000001111111111110000000111111;
    trainB[7]  = 32'b11111000000000000000000000111111;
    trainB[8]  = 32'b11111000000000000000000000111111;
    trainB[9]  = 32'b10000000111111111100000000111111;
    trainB[10] = 32'b00000001111111111110000000111111;
    trainB[11] = 32'b00000001111111111110000000111111;
    trainB[12] = 32'b00000001111111111110000000111111;
    trainB[13] = 32'b10000000111111111100000000111111;
    trainB[14] = 32'b11111000000000000000000000111111;
    trainB[15] = 32'b11111000000000000000000000111111;
end

	
	reg [9:0] ptxa = ITX; //posição do trem A em x
	reg [9:0] ptxb = ITX; //posição do trem B em x
	reg [9:0] ptya = ITYA;//posição do trem A em y
	reg [9:0] ptyb = ITYB;//posição do trem B em y
	
	logic [16:0] clock_dividerA = 0;
	logic [16:0] clock_dividerB = 0;
	localparam DIVIDER = 100000;
	localparam ITX = 520; //inicio do trem em x
	localparam ITYA = 52; //inicio do trem A em y 
	localparam ITYB = 172; //inicio do trem B em y
	
	
	always @(posedge clk or posedge reset)begin
		if(reset) begin
			ptxa <= ITX;
			ptya <= ITYA;
			clock_dividerA = 0;
			
		end else if(clock_dividerA == DIVIDER)begin
			if(ptya == 52 && ptxa > 60 && ptxa <= 580)begin
				ptxa <= ptxa - 1;
				clock_dividerA = 0;
			end if(ptxa == 60 && ptya >= 52 && ptya < 412)begin
				ptya <= ptya + 1;
				clock_dividerA = 0;
			end if(ptya == 412 && ptxa >= 60 && ptxa < 580)begin
				ptxa <= ptxa + 1;
				clock_dividerA = 0;
			end if(ptxa == 580 && ptya > 52 && ptya <= 412)begin
				ptya <= ptya - 1;
				clock_dividerA = 0;
			end if(ptxb == 120 && ptxa == 60 && ptya >= 60 && ptya < 300)begin
				clock_dividerA = 0;
			end	
		end else begin

				if(ptxa == 60 && s2 && ptya == 300)begin
				clock_dividerA = clock_dividerA;
			end else begin
				clock_dividerA <= clock_dividerA + 1;
				end
		end
	end //always
	
	always @(posedge clk or posedge reset)begin
		if(reset) begin
			ptxb <= ITX;
			ptyb <= ITYB;
			clock_dividerB = 0;
			
		end else if(clock_dividerB == DIVIDER)begin
			if(ptyb == 172 && ptxb > 120 && ptxb <= 520)begin
				ptxb <= ptxb - 1;
				clock_dividerB = 0;				
			end 
			
			if(ptxb == 120 && ptyb >= 172 && ptyb < 412)begin
				ptyb <= ptyb + 1;
				clock_dividerB = 0;		
			end 
			
			if(ptyb == 412 && ptxb >= 120 && ptxb < 520)begin
				ptxb <= ptxb + 1;
				clock_dividerB = 0;	
			end 
			
			if(ptxb == 520 && ptyb > 172 && ptyb <= 412)begin
				ptyb <= ptyb - 1;
				clock_dividerB = 0;
			end
			
		end else begin
		
		if(ptxb == 120 && s1 && ptyb == 300)begin
				clock_dividerB = clock_dividerB;
			end else begin
				clock_dividerB <= clock_dividerB + 1;
				end
		end
		
	end //always
	
	  
endmodule


