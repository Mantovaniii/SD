module vga_proc(
    input wire clk,            // Clock
    input wire reset,          // Reset
	 input [7:0] program_counter,
    input [15:0] register_A, memory_data_register_out, instruction_register,
    input wire [9:0] pixel_x,  // Posição X do pixel
    input wire [9:0] pixel_y,  // Posição Y do pixel
    output reg color_out       // Saída de cor
);

	// Parâmetros de exibição da pontuação
   localparam pc_X = 560; // Posição X do placar
   localparam pc_Y = 10;  // Posição Y do placar
	localparam rega_X = 560; // Posição X do placar
   localparam rega_Y = 30;  // Posição Y do placar
	localparam mem_X = 560; // Posição X do placar
   localparam mem_Y = 50;  // Posição Y do placar
	localparam ir_X = 560; // Posição X do placar
   localparam ir_Y = 70;  // Posição Y do placar
	reg color = 1;
	logic [15:0] pc ;       // Armazena a pontuação
	logic [15:0] rega ;       // Armazena a pontuação
	logic [15:0] mem ;       // Armazena a pontuação
	logic [15:0] ir ;       // Armazena a pontuação
	assign pc = program_counter; 
	assign rega = register_A;
	assign mem = memory_data_register_out;
	assign ir = instruction_register;
	
	// Definição de bitmaps para os números (5x7 pixels cada)
	reg [4:0] numeros [0:9][0:6]; 
	initial begin
		 // Número 0
		 numeros[0][0] = 5'b01110; numeros[0][1] = 5'b10001;
		 numeros[0][2] = 5'b10011; numeros[0][3] = 5'b10101;
		 numeros[0][4] = 5'b11001; numeros[0][5] = 5'b10001;
		 numeros[0][6] = 5'b01110;
		 
		 // Número 1
		 numeros[1][0] = 5'b00100; numeros[1][1] = 5'b01100;
		 numeros[1][2] = 5'b00100; numeros[1][3] = 5'b00100;
		 numeros[1][4] = 5'b00100; numeros[1][5] = 5'b00100;
		 numeros[1][6] = 5'b01110;
		 
		 // Número 2
		 numeros[2][0] = 5'b01110; numeros[2][1] = 5'b10001;
		 numeros[2][2] = 5'b00001; numeros[2][3] = 5'b00010;
		 numeros[2][4] = 5'b00100; numeros[2][5] = 5'b01000;
		 numeros[2][6] = 5'b11111;
		 
		 // Número 3
		 numeros[3][0] = 5'b01110; numeros[3][1] = 5'b10001;
		 numeros[3][2] = 5'b00001; numeros[3][3] = 5'b00110;
		 numeros[3][4] = 5'b00001; numeros[3][5] = 5'b10001;
		 numeros[3][6] = 5'b01110;
		 
		 // Número 4
		 numeros[4][0] = 5'b00010; numeros[4][1] = 5'b00110;
		 numeros[4][2] = 5'b01010; numeros[4][3] = 5'b10010;
		 numeros[4][4] = 5'b11111; numeros[4][5] = 5'b00010;
		 numeros[4][6] = 5'b00010;
		 
		 // Número 5
		 numeros[5][0] = 5'b11111; numeros[5][1] = 5'b10000;
		 numeros[5][2] = 5'b11110; numeros[5][3] = 5'b00001;
		 numeros[5][4] = 5'b00001; numeros[5][5] = 5'b10001;
		 numeros[5][6] = 5'b01110;
		 
		 // Número 6
		 numeros[6][0] = 5'b01110; numeros[6][1] = 5'b10001;
		 numeros[6][2] = 5'b10000; numeros[6][3] = 5'b11110;
		 numeros[6][4] = 5'b10001; numeros[6][5] = 5'b10001;
		 numeros[6][6] = 5'b01110;
		 
		 // Número 7
		 numeros[7][0] = 5'b11111; numeros[7][1] = 5'b00001;
		 numeros[7][2] = 5'b00010; numeros[7][3] = 5'b00100;
		 numeros[7][4] = 5'b01000; numeros[7][5] = 5'b01000;
		 numeros[7][6] = 5'b01000;
		 
		 // Número 8
		 numeros[8][0] = 5'b01110; numeros[8][1] = 5'b10001;
		 numeros[8][2] = 5'b10001; numeros[8][3] = 5'b01110;
		 numeros[8][4] = 5'b10001; numeros[8][5] = 5'b10001;
		 numeros[8][6] = 5'b01110;
		 
		 // Número 9
		 numeros[9][0] = 5'b01110; numeros[9][1] = 5'b10001;
		 numeros[9][2] = 5'b10001; numeros[9][3] = 5'b01111;
		 numeros[9][4] = 5'b00001; numeros[9][5] = 5'b10001;
		 numeros[9][6] = 5'b01110;
	end


	always @(posedge clk) begin
	 color_out = !color;

			
		  
		 
		  // Exibição da pontuação sempre
        if (pixel_y >= pc_Y && pixel_y < pc_Y + 7) begin
            // Unidade (último dígito da pontuação)
				  if (pixel_x >= pc_X + 40 && pixel_x < pc_X + 45) begin
						if (numeros[(pc % 10)][pixel_y - pc_Y][4 - (pixel_x - (pc_X + 40))])
							 color_out =color;
				  end
				  // Dezena (segundo dígito da pontuação)
				  if (pixel_x >= pc_X + 20 && pixel_x < pc_X + 25) begin
						if (numeros[((pc / 10) % 10)][pixel_y - pc_Y][4 - (pixel_x - (pc_X + 20))])
							 color_out =color;
				  end
				  // Centena (terceiro dígito da pontuação)
				  if (pixel_x >= pc_X && pixel_x < pc_X + 5) begin
						if (numeros[((pc / 100) % 10)][pixel_y - pc_Y][4 - (pixel_x - pc_X)])
							 color_out =color;
						end
        end
		  
		  
		  
		  
		  
		  
		  
		  // Exibição sempre
        if (pixel_y >= rega_Y && pixel_y < rega_Y + 7) begin
            // Unidade (último dígito da pontuação)
				  if (pixel_x >= rega_X + 40 && pixel_x < rega_X + 45) begin
						if (numeros[(rega % 10)][pixel_y - rega_Y][4 - (pixel_x - (rega_X + 40))])
							 color_out =color;
				  end
				  // Dezena (segundo dígito da pontuação)
				  if (pixel_x >= rega_X + 20 && pixel_x < rega_X + 25) begin
						if (numeros[((rega / 10) % 10)][pixel_y - rega_Y][4 - (pixel_x - (rega_X + 20))])
							 color_out =color;
				  end
				  // Centena (terceiro dígito da pontuação)
				  if (pixel_x >= rega_X && pixel_x < rega_X + 5) begin
						if (numeros[((rega / 100) % 10)][pixel_y - rega_Y][4 - (pixel_x - rega_X)])
							 color_out =color;
						end
        end 
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  // Exibição da pontuação sempre
        if (pixel_y >= mem_Y && pixel_y < mem_Y + 7) begin
            // Unidade (último dígito da pontuação)
				  if (pixel_x >= mem_X + 40 && pixel_x < mem_X + 45) begin
						if (numeros[(mem % 10)][pixel_y - mem_Y][4 - (pixel_x - (mem_X + 40))])
							 color_out =color;
				  end
				  // Dezena (segundo dígito da pontuação)
				  if (pixel_x >= mem_X + 20 && pixel_x < mem_X + 25) begin
						if (numeros[((mem / 10) % 10)][pixel_y - mem_Y][4 - (pixel_x - (mem_X + 20))])
							 color_out =color;
				  end
				  // Centena (terceiro dígito da pontuação)
				  if (pixel_x >= mem_X && pixel_x < mem_X + 5) begin
						if (numeros[((mem / 100) % 10)][pixel_y - mem_Y][4 - (pixel_x - mem_X)])
							 color_out =color;
						end
        end 
		  
		  
		  
		  
		  
		  // Exibição da pontuação sempre
        if (pixel_y >= ir_Y && pixel_y < ir_Y + 7) begin
            // Unidade (último dígito da pontuação)
				  if (pixel_x >= ir_X + 40 && pixel_x < ir_X + 45) begin
						if (numeros[(ir % 10)][pixel_y - ir_Y][4 - (pixel_x - (ir_X + 40))])
							 color_out =color;
				  end
				  // Dezena (segundo dígito da pontuação)
				  if (pixel_x >= ir_X + 20 && pixel_x < ir_X + 25) begin
						if (numeros[((ir / 10) % 10)][pixel_y - ir_Y][4 - (pixel_x - (ir_X + 20))])
							 color_out =color;
				  end
				  // Centena (terceiro dígito da pontuação)
				  if (pixel_x >= ir_X && pixel_x < ir_X + 5) begin
						if (numeros[((ir / 100) % 10)][pixel_y - ir_Y][4 - (pixel_x - ir_X)])
							 color_out =color;
						end
        end
	end
		  











endmodule 