module serial_send (
    input  logic       CLK, RST,
    input  logic [7:0] DATA_IN,
    input  logic       WE,
    output logic       DATA_OUT,
    output logic       BUSY);

    parameter  WAIT_DIV = 868; // 868 = 100 MHz / 115.2 kbps
    localparam WAIT_LEN = $clog2(WAIT_DIV);

    //状態と内部信号の宣言
    typedef enum {
        STATE_IDLE,
        STATE_SEND
    } state_type;
    state_type           state, n_state;
    logic          [9:0] data_reg, n_data_reg;
    logic [WAIT_LEN-1:0] wait_cnt, n_wait_cnt;
    logic          [3:0] bit_cnt, n_bit_cnt;

    //組み合わせ回路部分
    assign DATA_OUT = data_reg[0]; //出力データの設定

    always_comb begin
        BUSY       = 1'b0;
        n_state    = state;
        n_wait_cnt = wait_cnt;
        n_bit_cnt  = bit_cnt;
        n_data_reg = data_reg;
        if (state == STATE_IDLE) begin
            if (WE) begin
                n_state    = STATE_SEND;
                n_data_reg = {1'b1, DATA_IN, 1'b0};
                
            end
        end else if (state == STATE_SEND) begin
            BUSY       = 1'b1;
            if (wait_cnt == WAIT_DIV - 1) begin
                if (bit_cnt == 4'd9) begin
                    n_state    = STATE_IDLE;
                    n_wait_cnt = 0;
                    n_bit_cnt  = 4'd0;
                    n_data_reg = {1'b1, data_reg[9:1]};
                    end else if (bit_cnt == 4'd0) begin
                    n_data_reg = data_reg;
                    n_wait_cnt = 0;
                    n_bit_cnt  = bit_cnt + 1'b1;
                end else begin
                    n_data_reg = {1'b1, data_reg[9:1]};
                    n_wait_cnt = 0;
                    n_bit_cnt  = bit_cnt + 1'b1;
                end
            end else begin
                n_wait_cnt = wait_cnt + 1'b1;
            end
        end
    end

    //記憶回路部分
    always_ff @ (posedge CLK) begin
        if (RST) begin
            state    <= STATE_IDLE;
            wait_cnt <= WAIT_DIV - 1;
            bit_cnt  <= 4'd0;
            data_reg <= 10'h3ff;
        end else begin
            state    <= n_state;
            wait_cnt <= n_wait_cnt;
            bit_cnt  <= n_bit_cnt;
            data_reg <= n_data_reg;
        end
    end
endmodule