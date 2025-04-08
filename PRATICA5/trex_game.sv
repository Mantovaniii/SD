module trex_game(
    input wire clk,            // Clock
    input wire reset,          // Reset
    input wire botao,          // Botão de pular
    input wire [9:0] pixel_x,  // Posição X do pixel
    input wire [9:0] pixel_y,  // Posição Y do pixel
    output reg color_out       // Saída de cor
);

	reg game_over = 0; // Variável para controlar o estado do jogo
	
  // Registrador para exibição da pontuação
	reg [25:0] score_clk_div = 0;  // Aumentado para 26 bits (reduz ainda mais a velocidade)
	reg [15:0] score = 0;       // Armazena a pontuação
	
	reg [23:0] contador_clock = 0;  // Contador para movimentação
	reg [23:0] limite_clock = 200000; // Começa BEM DEVAGAR

    // Parâmetros do T-Rex
    localparam TREX_X = 50;
    localparam TREX_Y = 400;
    localparam TREX_WIDTH = 16;
    localparam TREX_HEIGHT = 16;
	 
	     // Parâmetros de exibição da pontuação
    localparam SCORE_X = 560; // Posição X do placar
    localparam SCORE_Y = 10;  // Posição Y do placar

    reg [9:0] trex_y = TREX_Y; // Posição vertical do T-Rex
    reg jumping = 0;

	 // Adicionando variáveis para pulo suave
	reg [1:0] estado_pulo = NO_CHAO;             // Máquina de estados para o pulo
	// Definição da altura máxima do pulo
	localparam NO_CHAO = 0, SUBINDO = 1, DESCENDO = 2;
	localparam ALTURA_MAXIMA = TREX_Y - 40;  // Define o quão alto o T-Rex pode pular

    // Parâmetros do chão
     localparam CHAO_Y_START = 420; // Subindo o chão para uma posição mais alta
		localparam CHAO_Y_END   = 430; // Novo limite inferior para o chão
		reg [9:0] chao_pos = 0;

	// Registrador para gerar números pseudoaleatórios (LFSR - Linear Feedback Shift Register)
	reg [7:0] lfsr = 8'b10101011;  // Valor inicial do LFSR

	// Divisor de clock ajustável para os obstáculos
	reg [15:0] obstaculo_divisor = 150000;

    // Parâmetros do cacto
    localparam CACTO_Y = 400;
    localparam CACTO_WIDTH = 16;
    localparam CACTO_HEIGHT = 16;
    reg [9:0] cacto_x = 640;

	  // Posição inicial do obstáculo voador
localparam OBSTACULO_VOADOR_Y = 380; // Posição no ar
localparam OBSTACULO_VOADOR_WIDTH = 16;
localparam OBSTACULO_VOADOR_HEIGHT = 16;
reg [9:0] obstaculo_voador_x = 640; // Inicia no lado direito da tela
	 
	 reg [31:0] letter_G [0:31]; 
initial begin

   letter_G[0] = 32'b00000000000000000000000000000000;
	letter_G[1] = 32'b00000000000000000000000000000000;
	letter_G[2] = 32'b00000000000000000000000000000000;
	letter_G[3] = 32'b00000000000000000000000000000000;
	letter_G[4] = 32'b00000000001111111111111110000000;
	letter_G[5] = 32'b00000000001111111111111110000000;
	letter_G[6] = 32'b00000000011111111111111110000000;
	letter_G[7] = 32'b00000011111111000000011111110000;
	letter_G[8] = 32'b00000011111110000000011111111000;
	letter_G[9] = 32'b00000011111110000000011111111000;
	letter_G[10] = 32'b00111111110000000000000000000000;
	letter_G[11] = 32'b00111111110000000000000000000000;
	letter_G[12] = 32'b00111111110000000000000000000000;
	letter_G[13] = 32'b00111111110000000000000000000000;
	letter_G[14] = 32'b00111111110000000000000000000000;
	letter_G[15] = 32'b00111111110000000000000000000000;
	letter_G[16] = 32'b00111111110000000000000000000000;
	letter_G[17] = 32'b00111111110000000111111111110000;
	letter_G[18] = 32'b00111111110000000111111111111000;
	letter_G[19] = 32'b00111111110000000111111111111000;
	letter_G[20] = 32'b00111111110000000000011111111000;
	letter_G[21] = 32'b00111111110000000000011111111000;
	letter_G[22] = 32'b00111111110000000000011111111000;
	letter_G[23] = 32'b00111111110000000000011111111000;
	letter_G[24] = 32'b00000011111110000000011111111000;
	letter_G[25] = 32'b00000011111110000000011111111000;
	letter_G[26] = 32'b00000011111111000000011111110000;
	letter_G[27] = 32'b00000000001111111111111110000000;
	letter_G[28] = 32'b00000000001111111111111110000000;
	letter_G[29] = 32'b00000000001111111111111110000000;
	letter_G[30] = 32'b00000000000000000000000000000000;
	letter_G[31] = 32'b00000000000000000000000000000000;
end

 reg [31:0] letter_A [31:0];
  reg [31:0] letter_M [31:0];
  reg [31:0] letter_E [31:0];
  reg [31:0] letter_O [31:0];
  reg [31:0] letter_V [31:0];
  reg [31:0] letter_R [31:0];

  initial begin
    // Letra A
   letter_A[31] = 32'b00000000000000000000000000000000;
	letter_A[30] = 32'b00000000000011111111110000000000;
	letter_A[29] = 32'b00000000000011111111110000000000;
	letter_A[28] = 32'b00000000000011111111110000000000;
	letter_A[27] = 32'b00000000011111110001111111000000;
	letter_A[26] = 32'b00000000011111110001111111000000;
	letter_A[25] = 32'b00000000011111110001111111000000;
	letter_A[24] = 32'b00000011111110000000001111111000;
	letter_A[23] = 32'b00000111111100000000001111111000;
	letter_A[22] = 32'b00000111111100000000001111111000;
	letter_A[21] = 32'b00000111111100000000001111111000;
	letter_A[20] = 32'b00000111111100000000001111111000;
	letter_A[19] = 32'b00000111111100000000001111111000;
	letter_A[18] = 32'b00000111111100000000001111111000;
	letter_A[17] = 32'b00000111111100000000001111111000;
	letter_A[16] = 32'b00000111111111111111111111111000;
	letter_A[15] = 32'b00000111111111111111111111111000;
	letter_A[14] = 32'b00000111111111111111111111111000;
	letter_A[13] = 32'b00000111111100000000001111111000;
	letter_A[12] = 32'b00000111111100000000001111111000;
	letter_A[11] = 32'b00000111111100000000001111111000;
	letter_A[10] = 32'b00000111111100000000001111111000;
	letter_A[9] = 32'b00000111111100000000001111111000;
	letter_A[8] = 32'b00000111111100000000001111111000;
	letter_A[7] = 32'b00000111111100000000001111111000;
	letter_A[6] = 32'b00000011111100000000000111111000;
	letter_A[5] = 32'b00000000000000000000000000000000;
	letter_A[4] = 32'b00000000000000000000000000000000;
	letter_A[3] = 32'b00000000000000000000000000000000;
	letter_A[2] = 32'b00000000000000000000000000000000;
	letter_A[1] = 32'b00000000000000000000000000000000;
	letter_A[0] = 32'b00000000000000000000000000000000;
    
    // Letra M
   letter_M[31] = 32'b00000000000000000000000000000000;
	letter_M[30] = 32'b00000000000000000000000000000000;
	letter_M[29] = 32'b00000000000000000000000000000000;
	letter_M[28] = 32'b00000000000000000000000000000000;
	letter_M[27] = 32'b00000000000000000000000000000000;
	letter_M[26] = 32'b00011111110000000000011111110000;
	letter_M[25] = 32'b00011111110000000000011111110000;
	letter_M[24] = 32'b00011111110000000000001111110000;
	letter_M[23] = 32'b00011111110000000000011111110000;
	letter_M[22] = 32'b00011111111100000001111111110000;
	letter_M[21] = 32'b00011111111100000001111111110000;
	letter_M[20] = 32'b00011111111100000001111111110000;
	letter_M[19] = 32'b00011111001100000001110011110000;
	letter_M[18] = 32'b00011110001100000001100011110000;
	letter_M[17] = 32'b00011110001111000111100011110000;
	letter_M[16] = 32'b00011110001111000111100011110000;
	letter_M[15] = 32'b00011110001111000111100011110000;
	letter_M[14] = 32'b00011110001111101111100011110000;
	letter_M[13] = 32'b00011110000011111110000011110000;
	letter_M[12] = 32'b00011110000011111110000011110000;
	letter_M[11] = 32'b00011110000011111110000011110000;
	letter_M[10] = 32'b00011110000011111110000011110000;
	letter_M[9] = 32'b00011110000011111110000011110000;
	letter_M[8] = 32'b00011110000000111000000011110000;
	letter_M[7] = 32'b00011110000000011000000011110000;
	letter_M[6] = 32'b00000000000000000000000000000000;
	letter_M[5] = 32'b00000000000000000000000000000000;
	letter_M[4] = 32'b00000000000000000000000000000000;
	letter_M[3] = 32'b00000000000000000000000000000000;
	letter_M[2] = 32'b00000000000000000000000000000000;
	letter_M[1] = 32'b00000000000000000000000000000000;
	letter_M[0] = 32'b00000000000000000000000000000000;
  end  
   initial begin
   letter_E[0] = 32'b00000000000000000000000000000000;
	letter_E[1] = 32'b00000000000000000000000000000000;
	letter_E[2] = 32'b00000000000000000000000000000000;
	letter_E[3] = 32'b00000000000000000000000000000000;
	letter_E[4] = 32'b00000000000000000000000000000000;
	letter_E[5] = 32'b00011111111111111111111111100000;
	letter_E[6] = 32'b00111111111111111111111111100000;
	letter_E[7] = 32'b00111111111111111111111111100000;
	letter_E[8] = 32'b00111111110000000000000000000000;
	letter_E[9] = 32'b00111111100000000000000000000000;
	letter_E[10] = 32'b00111111100000000000000000000000;
	letter_E[11] = 32'b00111111100000000000000000000000;
	letter_E[12] = 32'b00111111100000000000000000000000;
	letter_E[13] = 32'b00111111100000000000000000000000;
	letter_E[14] = 32'b00111111110000000000000000000000;
	letter_E[15] = 32'b00111111111111111111000000000000;
	letter_E[16] = 32'b00111111111111111111000000000000;
	letter_E[17] = 32'b00111111111111111111000000000000;
	letter_E[18] = 32'b00111111100000000000000000000000;
	letter_E[19] = 32'b00111111100000000000000000000000;
	letter_E[20] = 32'b00111111100000000000000000000000;
	letter_E[21] = 32'b00111111100000000000000000000000;
	letter_E[22] = 32'b00111111100000000000000000000000;
	letter_E[23] = 32'b00111111100000000000000000000000;
	letter_E[24] = 32'b00111111110000000000000000000000;
	letter_E[25] = 32'b00111111111111111111111111100000;
	letter_E[26] = 32'b00111111111111111111111111100000;
	letter_E[27] = 32'b00011111111111111111111111100000;
	letter_E[28] = 32'b00000000000000000000000000000000;
	letter_E[29] = 32'b00000000000000000000000000000000;
	letter_E[30] = 32'b00000000000000000000000000000000;
	letter_E[31] = 32'b00000000000000000000000000000000;
end
    
    initial begin
   letter_O[0] = 32'b00000000000000000000000000000000;
	letter_O[1] = 32'b00000000000000000000000000000000;
	letter_O[2] = 32'b00000000000000000000000000000000;
	letter_O[3] = 32'b00000111111111111111111110000000;
	letter_O[4] = 32'b00000111111111111111111110000000;
	letter_O[5] = 32'b00000111111111111111111110000000;
	letter_O[6] = 32'b01111111100000000000011111111000;
	letter_O[7] = 32'b01111111100000000000011111111000;
	letter_O[8] = 32'b01111111100000000000011111111000;
	letter_O[9] = 32'b01111111100000000000011111111000;
	letter_O[10] = 32'b01111111100000000000011111111000;
	letter_O[11] = 32'b01111111100000000000011111111000;
	letter_O[12] = 32'b01111111100000000000011111111000;
	letter_O[13] = 32'b01111111100000000000011111111000;
	letter_O[14] = 32'b01111111100000000000011111111000;
	letter_O[15] = 32'b01111111100000000000011111111000;
	letter_O[16] = 32'b01111111100000000000011111111000;
	letter_O[17] = 32'b01111111100000000000011111111000;
	letter_O[18] = 32'b01111111100000000000011111111000;
	letter_O[19] = 32'b01111111100000000000011111111000;
	letter_O[20] = 32'b01111111100000000000011111111000;
	letter_O[21] = 32'b01111111100000000000011111111000;
	letter_O[22] = 32'b01111111100000000000011111111000;
	letter_O[23] = 32'b01111111100000000000011111111000;
	letter_O[24] = 32'b01111111100000000000011111111000;
	letter_O[25] = 32'b00111111100000000000111111110000;
	letter_O[26] = 32'b00000111111111111111111110000000;
	letter_O[27] = 32'b00000111111111111111111110000000;
	letter_O[28] = 32'b00000111111111111111111110000000;
	letter_O[29] = 32'b00000000000000000000000000000000;
	letter_O[30] = 32'b00000000000000000000000000000000;
	letter_O[31] = 32'b00000000000000000000000000000000;
end
    
    initial begin
   letter_V[31] = 32'b00000000000000000000000000000000;
	letter_V[30] = 32'b00000000000000000000000000000000;
	letter_V[29] = 32'b00000000000000000000000000000000;
	letter_V[28] = 32'b00000000000000000000000000000000;
	letter_V[27] = 32'b00011111110000000000000111111110;
	letter_V[26] = 32'b00011111111000000000000111111110;
	letter_V[25] = 32'b00011111111000000000000111111110;
	letter_V[24] = 32'b00011111111000000000000111111110;
	letter_V[23] = 32'b00011111111000000000000111111110;
	letter_V[22] = 32'b00011111111000000000000111111110;
	letter_V[21] = 32'b00011111111000000000000111111110;
	letter_V[20] = 32'b00011111111000000000000111111110;
	letter_V[19] = 32'b00011111111000000000000111111110;
	letter_V[18] = 32'b00011111111000000000000111111110;
	letter_V[17] = 32'b00011111111000000000000111111110;
	letter_V[16] = 32'b00011111111000000000000111111110;
	letter_V[15] = 32'b00011111111000000000000111111110;
	letter_V[14] = 32'b00011111111000000000000111111110;
	letter_V[13] = 32'b00011111111000000000000111111110;
	letter_V[12] = 32'b00011111111000000000000111111110;
	letter_V[11] = 32'b00011111111000000000000111111110;
	letter_V[10] = 32'b00011111111000000000000111111110;
	letter_V[9] = 32'b00011111111000000000000111111110;
	letter_V[8] = 32'b00000001111111111111111111100000;
	letter_V[7] = 32'b00000001111111111111111111100000;
	letter_V[6] = 32'b00000001111111111111111111100000;
	letter_V[5] = 32'b00000000000111111111111000000000;
	letter_V[4] = 32'b00000000000111111111111000000000;
	letter_V[3] = 32'b00000000000111111111111000000000;
	letter_V[2] = 32'b00000000000000000000000000000000;
	letter_V[1] = 32'b00000000000000000000000000000000;
	letter_V[0] = 32'b00000000000000000000000000000000;
end
   initial begin
   letter_R[0] = 32'b00000000000000000000000000000000;
	letter_R[1] = 32'b00000000000000000000000000000000;
	letter_R[2] = 32'b00000000000000000000000000000000;
	letter_R[3] = 32'b00000000000000000000000000000000;
	letter_R[4] = 32'b00000111111000000000001111100000;
	letter_R[5] = 32'b00000111111000000000011111110000;
	letter_R[6] = 32'b00000111111000000000011111110000;
	letter_R[7] = 32'b00000111111000000000011111110000;
	letter_R[8] = 32'b00000111111000000000011111110000;
	letter_R[9] = 32'b00000111111000000000011111110000;
	letter_R[10] = 32'b00000111111000000000011111110000;
	letter_R[11] = 32'b00000111111100000000011111100000;
	letter_R[12] = 32'b00000111111111111111111100000000;
	letter_R[13] = 32'b00000111111111111111111100000000;
	letter_R[14] = 32'b00000111111111111111111110000000;
	letter_R[15] = 32'b00000111111000000000011111110000;
	letter_R[16] = 32'b00000111111000000000011111110000;
	letter_R[17] = 32'b00000111111000000000011111110000;
	letter_R[18] = 32'b00000111111000000000011111110000;
	letter_R[19] = 32'b00000111111000000000011111110000;
	letter_R[20] = 32'b00000111111000000000011111110000;
	letter_R[21] = 32'b00000111111000000000011111110000;
	letter_R[22] = 32'b00000111111000000000011111110000;
	letter_R[23] = 32'b00000111111000000000011111110000;
	letter_R[24] = 32'b00000111111000000000011111110000;
	letter_R[25] = 32'b00000111111111111111111100000000;
	letter_R[26] = 32'b00000111111111111111111100000000;
	letter_R[27] = 32'b00000111111111111111111100000000;
	letter_R[28] = 32'b00000000000000000000000000000000;
	letter_R[29] = 32'b00000000000000000000000000000000;
	letter_R[30] = 32'b00000000000000000000000000000000;
	letter_R[31] = 32'b00000000000000000000000000000000;
end
  
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

reg color = 1;

    
    // Parâmetros para a posição do "GAME OVER"
    localparam GAME_OVER_X_START = 240;
    localparam GAME_OVER_Y_START = 180;
	 
    // Matriz do T-Rex
    reg [TREX_WIDTH-1:0] trex [0:TREX_HEIGHT-1];
    initial begin
        trex[0]  = 16'b0000001111000000;
        trex[1]  = 16'b0000111111110000;
        trex[2]  = 16'b0001111111111000;
        trex[3]  = 16'b0011111011111100;
        trex[4]  = 16'b0111111111111110;
        trex[5]  = 16'b0011111111111110;
        trex[6]  = 16'b0000111111111111;
        trex[7]  = 16'b0000000111111111;
        trex[8]  = 16'b0000000111111111;
        trex[9]  = 16'b0000111111111111;
        trex[10] = 16'b0011111111111110;
        trex[11] = 16'b0111111111111110;
        trex[12] = 16'b0011111111111100;
        trex[13] = 16'b0001111111111000;
        trex[14] = 16'b0000111111110000;
        trex[15] = 16'b0000001111000000;
    end

    // Matriz do Cacto (ghost)
    reg [CACTO_WIDTH-1:0] ghost [0:CACTO_HEIGHT-1];
    initial begin
        ghost[0]  = 16'b0000000000000000;
        ghost[1]  = 16'b0000001111000000;
        ghost[2]  = 16'b0000111111110000;
        ghost[3]  = 16'b0001111111111000;
        ghost[4]  = 16'b0011100111100100;
        ghost[5]  = 16'b0011000011000000;
        ghost[6]  = 16'b0011001111001100;
        ghost[7]  = 16'b0111001111001110;
        ghost[8]  = 16'b0111100111100110;
        ghost[9]  = 16'b0111111111111110;
        ghost[10] = 16'b0111111111111110;
        ghost[11] = 16'b0111111111111110;
        ghost[12] = 16'b0111111111111110;
        ghost[13] = 16'b0110111001110110;
        ghost[14] = 16'b0100011001100010;
        ghost[15] = 16'b0000000000000000;
    end
	 
	 // Matriz do obstáculo voador
reg [15:0] obstaculo_voador [0:15];
initial begin

    obstaculo_voador[0] = 16'b0000000000000000;
    obstaculo_voador[1] = 16'b0000000000000000;
    obstaculo_voador[2] = 16'b0000000010000000;
    obstaculo_voador[3] = 16'b0000000100000000;
    obstaculo_voador[4] = 16'b0000000110000000;
    obstaculo_voador[5] = 16'b0000001111000000;
    obstaculo_voador[6] = 16'b0000001110100000;
    obstaculo_voador[7] = 16'b0000001111100000;
    obstaculo_voador[8] = 16'b0000001111100000;
    obstaculo_voador[9] = 16'b0000000111100000;
    obstaculo_voador[10] = 16'b0000000111100000;
    obstaculo_voador[11] = 16'b0000000111000000;
    obstaculo_voador[12] = 16'b0000001110000000;
    obstaculo_voador[13] = 16'b0000011100000000;
    obstaculo_voador[14] = 16'b0000000000000000;
    obstaculo_voador[15] = 16'b0000000000000000;
end
	 



    // Variável para dividir o clock
    reg [15:0] clock_divider = 0;  // Contador para dividir a frequência do clock
    localparam DIVIDER = 60000;     // Número de ciclos do clock para mover o chão mais devagar
	 reg slowclk = 0;

// Movimento do chão, cacto e pulo do T-Rex
always @(posedge clk or posedge reset) begin
    if (reset) begin
        chao_pos <= 0;
        cacto_x <= 640;
		  score_clk_div <= 0;
        trex_y <= TREX_Y;
        jumping <= 0;
        obstaculo_voador_x <= 640;
		  color <='b01; 
        clock_divider <= 0;
		  score <= 0;
		  contador_clock = 0;
		  limite_clock = 700000;
		  lfsr <= 8'b10101011;  // Reinicia o gerador pseudoaleatório
        game_over <= 0;   // Jogo iniciado
    end else if (!game_over) begin  // Só faz movimento se o jogo não estiver parado  
		  if (score_clk_div >= 5000000) begin  // Ajuste para alterar a velocidade da pontuação
            score_clk_div <= 0;
            score <= score + 1;
			
			if (score == 6) 
				 limite_clock <= 100000; // Pouco mais rápido
			else if (score == 30) 
				 limite_clock <= 80000;
			else if (score == 100) 
				 limite_clock <= 70000;
			else if (score == 150) 
				 limite_clock <= 60000;
			else if (score == 200) 
				 limite_clock <= 50000;
			else if (score == 250) 
				 limite_clock <= 40000;
			 else if (score > 300)
				 limite_clock <= limite_clock - 5000;

			if (score > 50) begin
				color = 'b00;
			end
			if (score > 100) begin
				color = 'b01;
			end
			if (score > 200) begin
				color = 'b00;
			end
        end else begin
            score_clk_div <= score_clk_div + 1;
        end
		  if (contador_clock >= limite_clock) begin
			cacto_x <= cacto_x - 2;
			obstaculo_voador_x <= obstaculo_voador_x - 1;
			contador_clock <= 0;  // Reseta o contador
			end else begin
				 contador_clock <= contador_clock + 1;  // Continua contando
			end

        
        chao_pos <= (chao_pos == 20) ? 0 : chao_pos + 1;

        // Lógica do pulo do T-Rex
        if (botao) begin
            trex_y <= TREX_Y - 20;
        end else begin
            trex_y <= TREX_Y;
        end

        // Verificar colisão com o cacto ou o obstáculo voador
        if ((pixel_x >= cacto_x && pixel_x < cacto_x + CACTO_WIDTH &&
             pixel_y >= CACTO_Y && pixel_y < CACTO_Y + CACTO_HEIGHT &&
             pixel_x >= TREX_X && pixel_x < TREX_X + TREX_WIDTH &&
             pixel_y >= trex_y && pixel_y < trex_y + TREX_HEIGHT) ||

            (pixel_x >= obstaculo_voador_x && pixel_x < obstaculo_voador_x + OBSTACULO_VOADOR_WIDTH &&
             pixel_y >= OBSTACULO_VOADOR_Y && pixel_y < OBSTACULO_VOADOR_Y + OBSTACULO_VOADOR_HEIGHT &&
             pixel_x >= TREX_X && pixel_x < TREX_X + TREX_WIDTH &&
             pixel_y >= trex_y && pixel_y < trex_y + TREX_HEIGHT)) begin
            // Colisão detectada, parar o jogo
            game_over <= 1;  // Jogo interrompido
        end
    end
end

  always @(posedge clk) begin
        color_out = !color;

		// Desenho do chão otimizado (padrão de faixas)
		if (pixel_y >= CHAO_Y_START && pixel_y < CHAO_Y_END) begin
			 if ((pixel_x + chao_pos) % 20 < 10)
				  color_out = color;
		end
		 

        // Desenho do cacto
        if (pixel_x >= cacto_x && pixel_x < cacto_x + CACTO_WIDTH &&
            pixel_y >= CACTO_Y && pixel_y < CACTO_Y + CACTO_HEIGHT) begin
            if (ghost[pixel_y - CACTO_Y][CACTO_WIDTH - (pixel_x - cacto_x) - 1])
                color_out =color;
        end

        // Desenho do T-Rex
        if (pixel_x >= TREX_X && pixel_x < TREX_X + TREX_WIDTH &&
            pixel_y >= trex_y && pixel_y < trex_y + TREX_HEIGHT) begin
            if (trex[pixel_y - trex_y][TREX_WIDTH - (pixel_x - TREX_X) - 1])
                color_out =color;
        end
		  
		  // Desenho do obstáculo voador
if (pixel_x >= obstaculo_voador_x && pixel_x < obstaculo_voador_x + OBSTACULO_VOADOR_WIDTH &&
    pixel_y >= OBSTACULO_VOADOR_Y && pixel_y < OBSTACULO_VOADOR_Y + OBSTACULO_VOADOR_HEIGHT) begin
    if (obstaculo_voador[pixel_y - OBSTACULO_VOADOR_Y][OBSTACULO_VOADOR_WIDTH - (pixel_x - obstaculo_voador_x) - 1])
        color_out =color;
end

// Exibição da pontuação sempre
        if (pixel_y >= SCORE_Y && pixel_y < SCORE_Y + 7) begin
            // Unidade (último dígito da pontuação)
        if (pixel_x >= SCORE_X + 40 && pixel_x < SCORE_X + 45) begin
            if (numeros[(score % 10)][pixel_y - SCORE_Y][4 - (pixel_x - (SCORE_X + 40))])
                color_out =color;
        end
        // Dezena (segundo dígito da pontuação)
        if (pixel_x >= SCORE_X + 20 && pixel_x < SCORE_X + 25) begin
            if (numeros[((score / 10) % 10)][pixel_y - SCORE_Y][4 - (pixel_x - (SCORE_X + 20))])
                color_out =color;
        end
        // Centena (terceiro dígito da pontuação)
        if (pixel_x >= SCORE_X && pixel_x < SCORE_X + 5) begin
            if (numeros[((score / 100) % 10)][pixel_y - SCORE_Y][4 - (pixel_x - SCORE_X)])
                color_out =color;
            end
        end
   
			
			 // Verificar se o jogo terminou (game over)
    if (game_over) begin
    // Desenhar as letras "G", "A", "M", "E", " ", "O", "V", "E", "R"
    // Cada letra será desenhada na tela nas posições adequadas
    if (pixel_x >= 100 && pixel_x < 132 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_G[pixel_y - 100][pixel_x - 100])  // Acesso corrigido
            color_out =color;
    end
    if (pixel_x >= 132 && pixel_x < 164 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_A[pixel_y - 100][pixel_x - 132])  // Acesso corrigido
            color_out =color;
    end
    if (pixel_x >= 164 && pixel_x < 196 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_M[pixel_y - 100][pixel_x - 164])  // Acesso corrigido
            color_out =color;
    end
    if (pixel_x >= 196 && pixel_x < 228 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_E[pixel_y - 100][pixel_x - 196])  // Acesso corrigido
            color_out =color;
    end
    // Continuar com as outras letras, ajustando as coordenadas conforme necessário.
    // Para o espaço, não precisa desenhar nada, apenas continuar com a próxima letra.
    if (pixel_x >= 228 && pixel_x < 260 && pixel_y >= 100 && pixel_y < 132) begin
        // Não desenhar nada para o espaço
        color_out = !color;
    end
    if (pixel_x >= 260 && pixel_x < 292 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_O[pixel_y - 100][pixel_x - 260])  // Acesso corrigido
            color_out =color;
    end
    if (pixel_x >= 292 && pixel_x < 324 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_V[pixel_y - 100][pixel_x - 292])  // Acesso corrigido
            color_out =color;
    end
    if (pixel_x >= 324 && pixel_x < 356 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_E[pixel_y - 100][pixel_x - 324])  // Acesso corrigido
            color_out =color;
    end
    if (pixel_x >= 356 && pixel_x < 388 && pixel_y >= 100 && pixel_y < 132) begin
        if (letter_R[pixel_y - 100][pixel_x - 356])  // Acesso corrigido
            color_out =color;
    end
	 
    end
end
endmodule
