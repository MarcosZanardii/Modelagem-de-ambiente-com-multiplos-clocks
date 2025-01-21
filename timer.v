module timer (
    input rst,               // reset do sistema, reinicia o timer
    input clk,               // clock do sistema, controla a atualização do contador
    input t_en,              // habilita o contador do timer quando em 1

    output t_valid,          // indica se a saída é válida (1 = válido)
    output reg [15:0] t_out  // saída do valor atual do timer
);
    
    // Processo sensível à borda de subida do clock e reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset: zera o contador do timer
            t_out <= 16'd0;   // t_out é zerado
        end
        else if (t_en) begin
            // Se t_en está ativo, incrementa o valor do timer
            t_out <= t_out + 16'd1;  // incrementa o valor do timer em 1 a cada ciclo
        end
    end

    // Lógica para indicar se a saída é válida
    assign t_valid = t_en ? 1'd1 : 1'd0; // t_valid é 1 se t_en está ativo, caso contrário, é 0

endmodule
