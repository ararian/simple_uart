module serial_fpga (
    input  logic CLK, RST,
    output logic TXD);

    typedef enum {
        STATE_SEND,
        STATE_WAIT,
        STATE_FIN
    } state_type;
    state_type  state, n_state;
    logic       we;
    logic       busy;
    logic [7:0] data_in;

    serial_send # (
            .WAIT_DIV(868))
        ser (
            .CLK(CLK),
            .RST(RST),
            .DATA_IN(data_in),
            .WE(we),
            .DATA_OUT(TXD),
            .BUSY(busy));

    assign data_in = 8'h41;

    always_comb begin
        n_state = state;
        we      = 1'b0;
        if (state == STATE_SEND) begin
            n_state = STATE_WAIT;
            we      = 1'b1;
        end else if (state == STATE_WAIT) begin
            if (~ busy) begin
                n_state = STATE_FIN;
            end
        end
    end

    always_ff @ (posedge CLK) begin
        if (RST) begin
            state <= STATE_SEND;
        end else begin
            state <= n_state;
        end
    end
endmodule