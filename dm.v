module dm (
  input rst, clk,                 // reset e clock de 100 MHz
  input [2:0] prog,               // sinal de programação do clock lento
  input [1:0] mod,                // módulo em uso (Fibonacci ou Timer)
  input [15:0] data_2,             // valor gerado pelo módulo ativo

  output [7:0] an,                // anodo ativo baixo para displays
  output [7:0] dec_cat            // dígito decodificado para o display atual
);

  reg [15:0] data;                         // registrador para armazenar data_2
  wire [3:0] mil, centena, dezena, unidade; // valores de milhar, centena, dezena, unidade
  wire [5:0] d1, d2, d3, d4, d6, d8;        // sinais para os displays

  // atribuições para os displays
  assign d1 = {1'b1, unidade, 1'b0};       // display de unidade
  assign d2 = {1'b1, dezena, 1'b0};        // display de dezena
  assign d3 = {1'b1, centena, 1'b0};       // display de centena
  assign d4 = {1'b1, mil, 1'b0};           // display de milhar
  assign d6 = {1'b1, 2'b0, mod, 1'b0};     // display do valor de mod
  assign d8 = {1'b1, 1'b0, prog, 1'b0};    // display do valor de prog

  // processamento de milhar, centena, dezena e unidade
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      data <= 16'b0;                        // reseta data
    end else begin
      data <= data_2;                        // armazena data_2 em data
    end
  end

  // cálculo dos dígitos de data
  assign mil     = data / 1000;            // milhar
  assign centena = (data % 1000) / 100;    // centena
  assign dezena  = (data % 100) / 10;      // dezena
  assign unidade = data % 10;              // unidade

  dspl_drv_NexysA7 DUT_DISPLAY(
    .clock(clk), 
    .reset(rst), 
    .d1(d1), 
    .d2(d2), 
    .d3(d3), 
    .d4(d4), 
    .d5(6'd0), 
    .d6(d6), 
    .d7(6'd0), 
    .d8(d8),
    .an(an),
    .dec_cat(dec_cat)
    );
endmodule
