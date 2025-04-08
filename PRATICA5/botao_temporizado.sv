module botao_temporizado(
    input wire clk,             // Clock principal
    input wire reset,           // Reset
    input wire botao,           // Sinal do botão
    output reg botao_pulo       // Sinal de "pulo" (1 quando pressionado)
);

    // Parâmetros para temporização
    localparam TEMPORIZADOR_MAX = 12499999;  // Tempo de espera entre pulos (ajustável conforme a frequência do clock)

    // Contador para debouncing e temporização
    reg [24:0] contagem_debounce; // Contador de debouncing
    reg [24:0] contagem_temporizador; // Contador do temporizador
    reg botao_reg;  // Registro para armazenar o estado do botão

    // Inicialização
    initial begin
        botao_pulo = 0;
        contagem_debounce = 0;
        contagem_temporizador = 0;
        botao_reg = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            botao_pulo <= 0;
            contagem_debounce <= 0;
            contagem_temporizador <= 0;
            botao_reg <= 0;
        end else begin
            // Debounce: espera que o botão tenha estabilidade
            if (contagem_debounce < TEMPORIZADOR_MAX) begin
                contagem_debounce <= contagem_debounce + 1;
            end else begin
                // Lê o estado do botão após a estabilidade (debounce)
                botao_reg <= botao;
            end

            // Temporizador para limitar o pulo
            if (contagem_temporizador < TEMPORIZADOR_MAX) begin
                contagem_temporizador <= contagem_temporizador + 1;
            end else begin
                // Se o botão foi pressionado e o temporizador passou
                if (botao_reg && !botao_pulo) begin
                    botao_pulo <= 1; // Permite o pulo
                    contagem_temporizador <= 0; // Reseta o temporizador para o próximo pulo
                end else if (!botao_reg) begin
                    botao_pulo <= 0; // Se o botão não estiver pressionado, desativa o pulo
                end
            end
        end
    end

endmodule