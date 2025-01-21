`define S_IDLE       6'b000001
`define S_COMM_F     6'b000010
`define S_WAIT_F     6'b000100
`define S_BUF_EMPTY  6'b001000
`define S_COMM_T     6'b010000
`define S_WAIT_T     6'b100000

module top 
(
  input rst, clk, start_f, start_t, stop_f_t, update,
  input [2:0] prog,

  output parity,
  output [5:0] led,
  output [7:0] an, dec_cat
);

  //REGS
  reg [5:0] EA, PE;
  reg [1:0] module_reg;

  //WIRES
  wire start_f_clear, start_t_clear, stop_f_t_clear, update_clear;//sinais limpos
  wire clk_1, clk_2;//clk_1 ->rapido, clk_2 ->lento
  wire f_en, f_valid, t_en, t_valid;//habilita produção
  wire data_1_en;//receb sinal de valid de f ou de t
  wire buffer_empty, buffer_full, data_2_valid;//sinais do buffer (wrapper)
  wire [15:0] f_out, t_out, data_1, data_2; //dados a se propagarem
  wire [2:0] prog_out;//mostra qual prog esta
  wire [1:0] mod;//qual modo, f ou t

  // sinal que controla o estado da máquina de estados
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      EA <= `S_IDLE;
    end 
    else begin
      EA <= PE;
    end
  end

  //sinais de entrada limpos
  edge_detector DUT_start_f (.clock(clk), .reset(rst), .din(start_f),   .rising(start_f_clear));
  edge_detector DUT_start_t (.clock(clk), .reset(rst), .din(start_t),   .rising(start_t_clear));
  edge_detector DUT_stop    (.clock(clk), .reset(rst), .din(stop_f_t),  .rising(stop_f_t_clear));
  edge_detector DUT_update  (.clock(clk), .reset(rst), .din(update),    .rising(update_clear));
  
  //-----------------------------------------MÓDULOS-----------------------------------------
  //FIBONACCI -> modulo que gera seq de fibonacii
  fibonacci DUT_FIBONACCI(.rst(rst), .clk(clk_1), .f_en(f_en), .f_valid(f_valid), .f_out(f_out));

  //TIMER -> modulo que gera timer
  timer DUT_TIMER(.rst(rst), .clk(clk_1), .t_en(t_en), .t_valid(t_valid), .t_out(t_out));

  //DCM -> modulo que gera clk_1 e clk_2
  dcm DUT_DCM(.rst(rst), .clk(clk), .update(update_clear), .prog_in(prog), .clk_1(clk_1), .clk_2(clk_2), .prog_out(prog_out));

  //DM -> modulo que controla a saida do display de 7 segmentos
  dm DUT_DM(.rst(rst), .clk(clk), .prog(prog_out), .mod(mod), .data_2(data_2), .an(an), .dec_cat(dec_cat));
  
  //WRAPPER -> modulo que controla buffer para leitura e escrita
  wrapper DUT_WRAPPER(.rst(rst), .clk_1(clk_1), .clk_2(clk_2), .data_1_en(data_1_en), .data_1(data_1), 
                      .buffer_empty(buffer_empty), .buffer_full(buffer_full), .data_2_valid(data_2_valid), .data_2(data_2));

  //-------------------------------------------FIOS-------------------------------------------

  //module_reg conforme a FSM
  always @(posedge clk or posedge rst) begin
    if(rst)begin
      module_reg <= 2'd0;
    end
    else begin
      module_reg <= (EA == `S_COMM_T || EA == `S_WAIT_T) ? 2'd2 : 
                    (EA == `S_COMM_F || EA == `S_WAIT_F) ? 2'd1 : module_reg;  
    end    
  end
  assign mod = (EA != `S_IDLE) ? module_reg : 2'd0;

  //seleção de valid
  assign data_1_en = f_valid | t_valid;

  //saida depende da seleção do modo
  assign data_1 = (EA == `S_COMM_T || EA == `S_WAIT_T) ? t_out : f_out;

  //f_en -> somente ativo em S_COM_F, "modo fibonacci"
  assign f_en = (EA == `S_COMM_F && ~buffer_full) ? 1'd1 : 1'd0;

  //t_en -> somente ativo em S_COM_T, "modo timer"
  assign t_en = (EA == `S_COMM_T && ~buffer_full) ? 1'd1 : 1'd0;


  //---------------------------------------------FSM---------------------------------------------
  always @(*) begin
    case (EA)
      `S_IDLE:      PE =  (start_f_clear)     ? `S_COMM_F :
                          (start_t_clear)     ? `S_COMM_T : `S_IDLE;

      `S_COMM_F:    PE =  (stop_f_t_clear)    ? `S_BUF_EMPTY :
                          (buffer_full)       ? `S_WAIT_F    : `S_COMM_F;

      `S_WAIT_F:    PE =  (stop_f_t_clear)    ? `S_BUF_EMPTY  :
                          (~buffer_full)      ? `S_COMM_F     : `S_WAIT_F;

      `S_BUF_EMPTY: PE =  (buffer_empty && ~data_2_valid) ? `S_IDLE : `S_BUF_EMPTY;

      `S_COMM_T:    PE =  (stop_f_t_clear)    ? `S_BUF_EMPTY :
                          (buffer_full)       ? `S_WAIT_T    : `S_COMM_T;

      `S_WAIT_T:    PE =  (stop_f_t_clear)    ? `S_BUF_EMPTY  :
                          (~buffer_full)      ? `S_COMM_T     : `S_WAIT_T;

      default:      PE = `S_IDLE;
    endcase
  end

  //led -> inidica qual estado que esta
  assign led =  (EA == `S_IDLE)       ? 6'b000001  : 
                (EA == `S_COMM_T)     ? 6'b000010  : 
                (EA == `S_WAIT_T)     ? 6'b000100  : 
                (EA == `S_BUF_EMPTY)  ? 6'b001000  : 
                (EA == `S_COMM_F)     ? 6'b010000  : 
                (EA == `S_WAIT_F)     ? 6'b100000  : 6'd0;

  //parity -> indica paridade dos bits do data
    assign parity = ^data_2; 

endmodule