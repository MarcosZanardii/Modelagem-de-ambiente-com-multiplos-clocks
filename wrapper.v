module wrapper 
(
  input rst, clk_1, clk_2, data_1_en,    // sinais de reset, clock rápido e lento, e enable de entrada
  input [15:0] data_1,                   // dado de 16 bits gerado pelo sistema

  output buffer_empty, buffer_full, data_2_valid, // flags e sinal de validade
  output reg [15:0] data_2               // dado de 16 bits consumido
);

  reg [15:0] t_buffer [0:7];             // buffer interno de 8 palavras de 16 bits
  reg [2:0] buffer_rd, buffer_wr;        // ponteiros de leitura e escrita (3 bits para 8 locais)

  // Lógica de escrita no buffer (clk_1 -> rápido)
  always @(posedge clk_1 or posedge rst) begin
    if (rst) begin
      buffer_wr <= 3'b0;                 // reseta o ponteiro de escrita
    end
    else begin
      if (data_1_en && ~buffer_full) begin
        t_buffer[buffer_wr] <= data_1;     // escreve o dado no buffer
        buffer_wr <= buffer_wr + 1;        // atualiza o ponteiro de escrita
      end
    end
  end

  // Lógica de leitura do buffer (clk_2 -> lento)
  always @(posedge clk_2 or posedge rst) begin
    if (rst) begin
      buffer_rd <= 3'b0;                 // reseta o ponteiro de leitura
    end
    else begin
      if (data_2_valid) begin
        data_2 <= t_buffer[buffer_rd];     // lê o dado do buffer
        buffer_rd <= buffer_rd + 1;        // atualiza o ponteiro de leitura
      end
    end
  end

  // Flags de controle: buffer vazio e buffer cheio
  assign buffer_empty = (buffer_rd == buffer_wr) ? 1'b1 : 1'b0;  // vazio se rd == wr
  assign buffer_full  = (buffer_wr == (buffer_rd - 1'b1)) || (buffer_rd == 3'b000 && buffer_wr == 3'b111); // cheio se a diferença entre rd e wr for 1
  assign data_2_valid = (~buffer_empty) ? 1'b1 : 1'b0;  // dado válido se o buffer não estiver vazio

endmodule
