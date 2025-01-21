module dcm (
    input rst,                // reset ativo alto para o módulo
    input clk,                // clock de referência de 100 MHz
    input update,             // sinal para atualizar o clk_2 com base em prog_in
    input [2:0] prog_in,      // sinal de programação para definir a frequência de clk_2

    output reg clk_1,         // clock rápido (10 Hz)
    output reg clk_2,         // clock lento, frequências variadas de acordo com prog_in
    output reg [2:0] prog_out // indica qual frequência clk_2 está gerando
);
    reg [22:0] cont_1;        // contador para clk_1
    reg [29:0] cont_2;        // contador para clk_2
    reg [29:0] var_cont;      // variável que define o limite do contador de clk_2

    // Clock clk_1 - Fixa 10 Hz
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cont_1 <= 23'd0;
            clk_1 <= 1'b0;
        end
        else begin
            if (cont_1 == 23'd4999999) begin
                clk_1 <= ~clk_1;       // alterna o estado de clk_1 a cada 50 ms (10 Hz)
                cont_1 <= 23'd0;
            end else begin
                cont_1 <= cont_1 + 1;
            end
        end
    end

    // Clock clk_2 - Frequência variável de acordo com prog_in
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cont_2 <= 30'd0;
            clk_2 <= 1'b0;
            var_cont <= 30'd4999999;  // valor inicial para clk_2 igual a 10 Hz
            prog_out <= 3'd0;
        end
        else begin
            if (cont_2 >= var_cont) begin
                clk_2 <= ~clk_2;          // alterna o estado de clk_2 com base em var_cont
                cont_2 <= 30'd0;
            end else begin
                cont_2 <= cont_2 + 1;
            end

            //ALTERAR LIMITES DE CONT******
            // Atualiza prog_out com prog_in e ajusta o valor de var_cont quando update está ativo
             if (update) begin
                prog_out <= prog_in;       // salva o estado atual de prog_in
                case (prog_in)
                    3'd0: var_cont <= 30'd4999999;     // 10 Hz
                    3'd1: var_cont <= 30'd9999999;     // 5 Hz
                    3'd2: var_cont <= 30'd19999999;    // 2.5 Hz
                    3'd3: var_cont <= 30'd49999999;    // 1 Hz
                    3'd4: var_cont <= 30'd79999999;    // 0.625 Hz
                    3'd5: var_cont <= 30'd159999999;   // 0.3125 Hz
                    3'd6: var_cont <= 30'd319999999;   // 0.15625 Hz
                    default: var_cont <= 30'd639999999; // 0.078125 Hz
                endcase
            end
        end
    end
endmodule
