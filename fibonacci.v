module fibonacci (
    input rst,               // reset do sistema, reinicia a sequência de fibonacci
    input clk,               // clock do sistema, controla a atualização dos valores
    input f_en,             // habilita a sequência fibonacci quando em 1

    output f_valid,          // indica se a saída é válida (1 = válido)
    output reg [15:0] f_out  // saída do número de fibonacci atual
);
    
    reg [15:0] a, b;         // registradores internos para armazenar os dois últimos números da sequência

    // processo sensível à borda de subida do clock e reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset: inicializa a sequência de fibonacci
            a <= 16'd0;      // primeira posição da sequência é 0
            b <= 16'd1;      // segunda posição da sequência é 1
            f_out <= 16'd0;  // saída inicial é 0
        end
        else if (f_en) begin
            // se f_en está ativo, calcula o próximo número de fibonacci
            f_out <= a;      // f_out recebe o valor de a (atual número da sequência)
            a <= b;          // a passa a ser o valor de b (próximo número na sequência)
            b <= a + b;      // b recebe a soma dos dois últimos valores (próximo valor na sequência)
        end
    end

    // lógica para indicar se a saída é válida
        assign f_valid = (f_en == 1'd1) ? 1'd1 : 1'd0;  // f_valid é 1 se f_en está ativo

endmodule