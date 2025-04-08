module TicTacToe (
    input clk, reset, player,        // Controle do clock, reset, e qual jogador (0 ou 1)
    input [0:3] position,            // Posição onde o jogador coloca seu símbolo (0-8)
    output reg [0:6] win1, win2,     // Displays para os jogadores (7 segmentos)
    output reg draw, game_over,      // Flags de vencedor, empate e fim de jogo
    output reg [0:17] board,         // Representação do tabuleiro de 3x3 em 18 bits
    output reg [0:8] leds            // LEDs para representar o estado do tabuleiro
);

    // Inicializando o tabuleiro com 2 bits para cada posição (2 bits por célula)
    reg [1:0] game_board [0:8];   // Cada posição agora tem 2 bits, 00 para vazio, 01 para jogador 1, 10 para jogador 2

    // Inicializar os sinais
    integer i;
    reg [1:0] current_player;           // Jogador atual (01 para jogador 1, 10 para jogador 2)

    // Função para verificar se há um vencedor
    function [1:0] check_winner();
        input [1:0] board[0:8];
        begin
            // Checar todas as linhas, colunas e diagonais
            // Linhas
            if (board[0] == board[1] && board[1] == board[2] && board[0] != 2'b00)
                check_winner = board[0];
            else if (board[3] == board[4] && board[4] == board[5] && board[3] != 2'b00)
                check_winner = board[3];
            else if (board[6] == board[7] && board[7] == board[8] && board[6] != 2'b00)
                check_winner = board[6];
            // Colunas
            else if (board[0] == board[3] && board[3] == board[6] && board[0] != 2'b00)
                check_winner = board[0];
            else if (board[1] == board[4] && board[4] == board[7] && board[1] != 2'b00)
                check_winner = board[1];
            else if (board[2] == board[5] && board[5] == board[8] && board[2] != 2'b00)
                check_winner = board[2];
            // Diagonais
            else if (board[0] == board[4] && board[4] == board[8] && board[0] != 2'b00)
                check_winner = board[0];
            else if (board[2] == board[4] && board[4] == board[6] && board[2] != 2'b00)
                check_winner = board[2];
            else
                check_winner = 2'b00; // Nenhum vencedor
        end
    endfunction

    // Inicialização e controle do jogo
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Resetar o estado do tabuleiro
            for (i = 0; i < 9; i = i + 1) begin
                game_board[i] <= 2'b00;  // 00 representa vazio
            end
            win1 <= ~(7'b0000000);  // Display vazio para Jogador 1
            win2 <= ~(7'b0000000);  // Display vazio para Jogador 2
            draw <= 0;
            game_over <= 0;
            leds <= 9'b0; // LEDs apagados
            current_player <= 2'b01; // Jogador 1 começa
        end
        else if (!game_over) begin
            // Verificar se a posição é válida (entre 0 e 8 e ainda não ocupada)
            if (position >= 0 && position < 9 && game_board[position] == 2'b00) begin
                // Atualiza a posição com o símbolo do jogador
                game_board[position] <= current_player; 
                // Atualizar os LEDs para mostrar a jogada
                leds[position] <= 1;

                // Verificar vitória
                if (check_winner(game_board) == 2'b01) begin
                    win1 <= ~(7'b0110000); // Exibir número 1
                    game_over <= 1;
                end
                else if (check_winner(game_board) == 2'b10) begin
                    win2 <= ~(7'b1101101); // Exibir número 2
                    game_over <= 1;
                end
                // Verificar empate
                else if (game_board[0] != 2'b00 && game_board[1] != 2'b00 && game_board[2] != 2'b00 &&
                         game_board[3] != 2'b00 && game_board[4] != 2'b00 && game_board[5] != 2'b00 &&
                         game_board[6] != 2'b00 && game_board[7] != 2'b00 && game_board[8] != 2'b00) begin
                    draw <= 1;
                    game_over <= 1;
                    win1 <= ~(7'b1111001); // Exibir 'D' para Draw
                end

                // Alternar jogador (não será executado se o jogo já acabou)
                if (!game_over) begin
                    current_player <= (current_player == 2'b01) ? 2'b10 : 2'b01; 
                end
            end
        end
    end

    // Atualizar o estado do tabuleiro para a saída 'board' (representação de 3x3 em 18 bits)
    always @(*) begin
        board[0:1] = game_board[0]; 
        board[2:3] = game_board[1]; 
        board[4:5] = game_board[2];
        board[6:7] = game_board[3]; 
        board[8:9] = game_board[4]; 
        board[10:11] = game_board[5];
        board[12:13] = game_board[6];
        board[14:15] = game_board[7];
        board[16:17] = game_board[8];
    end

endmodule
