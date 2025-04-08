module StockCarGame(
    input logic pclk,  // Clock da FPGA
    input logic reset, // Reset do jogo
    input logic move_left, // Botão para mover o carro para a esquerda
    input logic move_right, // Botão para mover o carro para a direita
    input logic video_on, // Sinal de ativação de vídeo
    input logic [9:0] x, y, // Coordenadas do pixel atual
    output logic red_out, green_out, blue_out, // Sinais de cor
    output logic horiz_sync_out, vert_sync_out // Sinais de sincronização VGA
);

    // Definição de parâmetros
    localparam CAR_WIDTH = 20;
    localparam CAR_HEIGHT = 70;
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    localparam TRACK_WIDTH = 240;
    localparam DIVIDER = 200000; // Controle de velocidade do jogo
    localparam BLOCK_WIDTH = 20;
    localparam BLOCK_HEIGHT = 70;
    localparam YELLOW_DELAY = 240;
    localparam MOVE_STEP = 1; // Movimento mais fluido do carro
    localparam AMBULANCE_SPEED = 2;
    localparam AMBULANCE_WAIT = 1000000; // Tempo de espera antes do reset
    localparam AMBULANCE_DIVIDER = 300000; // Controle de velocidade da ambulância
    localparam LINE_DIVIDER = 100000; // Controle da velocidade das faixas

    // Definição das variáveis de posição
    logic [9:0] car_x, car_y;
    logic [17:0] contador;
    logic [9:0] block_x, block_y;
    logic [9:0] block_yellow_x, block_yellow_y;
    logic [9:0] ambulance_x;
    logic [9:0] line_y;
    logic game_over;
    logic [20:0] ambulance_timer;
    logic [20:0] ambulance_contador;
    logic [17:0] line_contador;
    logic ambulance_active;
	 
	   // Matriz do carro (mapa de pixels)
    logic [29:0] car [0:42];
    initial begin
        car[0]  = 30'b000000000000000000000000000000;
        car[1]  = 30'b000000000000000000000000000000;
        car[2]  = 30'b000000001000111111100010000000;
        car[3]  = 30'b000000111000111111100011000000;
        car[4]  = 30'b000000111000111111100011000000;
        car[5]  = 30'b000000111111111111111111000000;
        car[6]  = 30'b000000111111111111111111000000;
        car[7]  = 30'b000011111111111111111111110000;
        car[8]  = 30'b000011111111111111111111110000;
        car[9]  = 30'b000011111111111111111111110000;
        car[10] = 30'b000011111111111111111111110000;
        car[11] = 30'b000011111111111111111111110000;
        car[12] = 30'b000011111111111111111111110000;
        car[13] = 30'b000011111111111111111111110000;
        car[14] = 30'b000011111111111111111111110000;
        car[15] = 30'b000000111111111111111111000000;
        car[16] = 30'b000000111111111111111111000000;
        car[17] = 30'b000011111111111111111111110000;
        car[18] = 30'b000011111111111111111111110000;
        car[19] = 30'b000000111111111111111111000000;
        car[20] = 30'b000000111111111111111111000000;
        car[21] = 30'b000000111111111111111111000000;
        car[22] = 30'b000000111111111111111111000000;
        car[23] = 30'b000000111111111111111111000000;
        car[24] = 30'b000000111111111111111111000000;
        car[25] = 30'b000000111111111111111111000000;
        car[26] = 30'b000000111111111111111111000000;
        car[27] = 30'b000000111111111111111111000000;
        car[28] = 30'b000000111111111111111111000000;
        car[29] = 30'b000011111111111111111111110000;
        car[30] = 30'b000011111111111111111111110000;
        car[31] = 30'b000011111111111111111111110000;
        car[32] = 30'b000011111111111111111111110000;
        car[33] = 30'b000011111111111111111111110000;
        car[34] = 30'b000011111111111111111111110000;
        car[35] = 30'b000011111111111111111111110000;
        car[36] = 30'b000011111111111111111111110000;
        car[37] = 30'b000000111111111111111111000000;
        car[38] = 30'b000000111111111111111111000000;
        car[39] = 30'b000000110000000000000011000000;
        car[40] = 30'b000000111111111111111111000000;
        car[41] = 30'b000000000000000000000000000000;
        car[42] = 30'b000000000000000000000000000000;
    end


    function logic [9:0] pseudo_random(input logic [9:0] seed);
        pseudo_random = (seed * 17 + 23) % (TRACK_WIDTH - BLOCK_WIDTH);
    endfunction

    // Procedimento de Reset
    task reset_game;
        car_x <= SCREEN_WIDTH / 2 - CAR_WIDTH / 2;
        car_y <= SCREEN_HEIGHT - 50;
        contador <= 0;
        block_y <= 0;
        block_x <= (SCREEN_WIDTH / 2 - TRACK_WIDTH / 2) + pseudo_random(3);
        block_yellow_y <= YELLOW_DELAY;
        block_yellow_x <= (SCREEN_WIDTH / 2 - TRACK_WIDTH / 2) + pseudo_random(7);
        ambulance_x <= SCREEN_WIDTH + 50; // Ambulância começa fora da pista
        game_over <= 0;
        ambulance_timer <= 0;
        ambulance_contador <= 0;
        line_contador <= 0;
        line_y <= 0;
        ambulance_active <= 0;
    endtask

    initial begin
        reset_game();
    end

    always_ff @(posedge pclk) begin
        if (reset) begin
            reset_game();
        end else if (!game_over) begin
            if (contador >= DIVIDER) begin
                contador <= 0;
                if (move_left && car_x > (SCREEN_WIDTH / 2 - TRACK_WIDTH / 2)) begin
                    car_x <= car_x - MOVE_STEP;
                end
                if (move_right && car_x < (SCREEN_WIDTH / 2 + TRACK_WIDTH / 2 - CAR_WIDTH)) begin
                    car_x <= car_x + MOVE_STEP;
                end
                if (block_y < SCREEN_HEIGHT) begin
                    block_y <= block_y + 3;
                end else begin
                    block_y <= 0;
                    block_x <= (SCREEN_WIDTH / 2 - TRACK_WIDTH / 2) + pseudo_random(block_x);
                end
                if (block_yellow_y < SCREEN_HEIGHT) begin
                    block_yellow_y <= block_yellow_y + 3;
                end else begin
                    block_yellow_y <= 0;
                    block_yellow_x <= (SCREEN_WIDTH / 2 - TRACK_WIDTH / 2) + pseudo_random(block_yellow_x);
                end
            end else begin
                contador <= contador + 1;
            end
            
            // Movimentação das faixas da pista
            if (line_contador >= LINE_DIVIDER) begin
                line_contador <= 0;
                if (line_y < SCREEN_HEIGHT) begin
                    line_y <= line_y + 1;
                end else begin
                    line_y <= 0;
                end
            end else begin
                line_contador <= line_contador + 1;
            end
            
            // Verificação de colisão
            if ((block_y + BLOCK_HEIGHT >= car_y && block_y <= car_y + CAR_HEIGHT && block_x + BLOCK_WIDTH >= car_x && block_x <= car_x + CAR_WIDTH) ||
                (block_yellow_y + BLOCK_HEIGHT >= car_y && block_yellow_y <= car_y + CAR_HEIGHT && block_yellow_x + BLOCK_WIDTH >= car_x && block_yellow_x <= car_x + CAR_WIDTH)) begin
                game_over <= 1;
                ambulance_x <= SCREEN_WIDTH + 50; // Inicia a ambulância fora da tela
                ambulance_timer <= 0;
                ambulance_contador <= 0;
                ambulance_active <= 1;
            end
				 end else if (ambulance_active) begin
            // Controle de velocidade da ambulância
            if (ambulance_contador >= AMBULANCE_DIVIDER) begin
                ambulance_contador <= 0;
                if (ambulance_x > car_x) begin
                    ambulance_x <= ambulance_x - AMBULANCE_SPEED;
                end else begin
                    reset_game();
                end
            end else begin
                ambulance_contador <= ambulance_contador + 1;
            end

        end
    end

    // Renderização do jogo
    always_ff @(posedge pclk) begin
        if (video_on) begin
            red_out <= 0;
            green_out <= 1;
            blue_out <= 0;

            // Desenhar pista
            if (x >= (SCREEN_WIDTH / 2 - TRACK_WIDTH / 2) && x < (SCREEN_WIDTH / 2 + TRACK_WIDTH / 2)) begin
                red_out <= 0;
                green_out <= 0;
                blue_out <= 0;
            end
				
				  // Desenhar blocos
            if (!game_over) begin
                if (y >= block_y && y < block_y + BLOCK_HEIGHT && x >= block_x && x < block_x + BLOCK_WIDTH) begin
                    red_out <= 0;
                    green_out <= 0;
                    blue_out <= 1;
                end
                if (y >= block_yellow_y && y < block_yellow_y + BLOCK_HEIGHT && x >= block_yellow_x && x < block_yellow_x + BLOCK_WIDTH) begin
                    red_out <= 1;
                    green_out <= 1;
                    blue_out <= 0;
                end
            end


            // Desenhar faixas centrais
            if (x >= (SCREEN_WIDTH / 2 - 5) && x <= (SCREEN_WIDTH / 2 + 5) && (y + line_y) % 40 < 20) begin
                red_out <= 1;
                green_out <= 1;
                blue_out <= 1;
            end
				
				 // Desenhar carro
            if (y >= car_y && y < car_y + CAR_HEIGHT && x >= car_x && x < car_x + CAR_WIDTH) begin
                red_out <= 1;
                green_out <= 0;
                blue_out <= 0;
            end
				 // Desenhar ambulância após colisão
            if (ambulance_active && y >= car_y && y < car_y + 50 && x >= ambulance_x && x < ambulance_x + 60) begin
                red_out <= 1;
                green_out <= 1;
                blue_out <= 1;
            end
        end else begin
            red_out <= 0;
            green_out <= 0;
            blue_out <= 0;
        end
    end
endmodule
