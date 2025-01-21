---

# **Circuito Produtor-Consumidor com Múltiplos Clocks**

Este projeto implementa um **circuito digital produtor-consumidor** com múltiplos domínios de clock, utilizando **Verilog**. O sistema inclui módulos de geração de dados, gerenciamento de clocks, controle de exibição em displays de 7 segmentos e uma interface de comunicação entre clocks rápidos e lentos. A implementação é destinada à prototipação em FPGA Nexys A7.

---

## **Objetivo**

Desenvolver e prototipar um sistema capaz de:
- Gerar dados (sequência de Fibonacci e números crescentes).
- Gerenciar clocks múltiplos (rápido e lento) em um circuito sincronizado.
- Armazenar e transferir dados entre domínios de clock usando buffers.
- Exibir informações nos displays de 7 segmentos do FPGA.

---

## **Descrição dos Módulos**

1. **Fibonacci:**  
   - Gera números da sequência de Fibonacci (16 bits).  
   - Controlado por sinais de habilitação (`f_en`) e validação (`f_valid`).  

2. **Timer:**  
   - Gera números positivos crescentes (16 bits).  
   - Controlado por sinais de habilitação (`t_en`) e validação (`t_valid`).  

3. **Digital Clock Manager (DCM):**  
   - Gera dois clocks a partir de um clock de referência de 100 MHz:
     - **Clock rápido:** 10 Hz.
     - **Clock lento:** Frequências configuráveis (10 Hz a 78.125 mHz).  
   - Configurável via sinal de programação (`prog_in`).  

4. **Display Manager (DM):**  
   - Exibe informações nos displays de 7 segmentos, incluindo:
     - Frequência do clock lento.
     - Dados gerados pelos módulos Fibonacci e Timer.

5. **Wrapper:**  
   - Gerencia a transferência de dados entre os domínios de clock rápido e lento.  
   - Implementa um buffer circular com flags (`buffer_full`, `buffer_empty`).  

6. **Módulo Top:**  
   - Integra todos os módulos e implementa uma máquina de estados finita (FSM) para controle do sistema:
     - Estados de produção, consumo, espera e repouso.

---

## **Máquina de Estados (FSM)**

A FSM do sistema possui os seguintes estados:
- **S_IDLE:** Estado inicial de repouso.
- **S_COMM_F:** Produção e consumo de dados pelo módulo Fibonacci.
- **S_WAIT_F:** Espera pelo esvaziamento do buffer (Fibonacci).
- **S_COMM_T:** Produção e consumo de dados pelo módulo Timer.
- **S_WAIT_T:** Espera pelo esvaziamento do buffer (Timer).
- **S_BUF_EMPTY:** Consumo dos dados restantes no buffer.

---

## **Prototipação em FPGA**

- **Plataforma:** FPGA Nexys A7 da Xilinx.
- **Interface de Controle:**
  - Botões:
    - `start_f`: Inicia/continua produção no módulo Fibonacci.
    - `start_t`: Inicia/continua produção no módulo Timer.
    - `stop_f_t`: Para a produção em ambos os módulos.
    - `update`: Atualiza a frequência do clock lento.
  - **Displays de 7 segmentos:** Exibem dados gerados e o estado do sistema.

---

## **Arquivos Disponíveis**

1. **Módulos a Implementar:**
   - `fibonacci.v`, `timer.v`, `dcm.v`, `dm.v`, `wrapper.v`, `top.v`.

2. **Módulos Auxiliares:**
   - `edge_detector.v`: Filtra sinais dos botões do FPGA.
   - `dspl_drv_NexysA7.v`: Interface de hardware para os displays de 7 segmentos.

3. **Suporte para Simulação:**
   - `tb.v`: Testbench inicial.
   - `sim.do`: Script para simulação.
   - `wave.do`: Script para formas de onda.

4. **Template de Mapeamento de Pinos:**
   - `Nexys-A7-100T-TP2.xdc`.

---
