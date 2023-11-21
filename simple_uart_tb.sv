`timescale 1ps/1ps

module simple_uart_tb();
    logic   CLK, RST;
    logic   [7:0]   DATA_IN;
    logic   WE, DATA_OUT, BUSY;

    parameter STEP = 200;
    serial_send #(.WAIT_DIV(5)) si_uart (.CLK(CLK), .RST(RST), .DATA_IN(DATA_IN), .WE(WE), .DATA_OUT(DATA_OUT), .BUSY(BUSY));

    always begin
        CLK <= 1'b1; #10;
        CLK <= 1'b0; #10;
    end

    initial begin
        RST <= 1'b1; #30;
        RST <= 1'b0;
    end

    assign DATA_IN = 8'h41;

    initial begin
        WE <= 1'b0; #90;
        WE <= 1'b1; #20;
        WE <= 1'b0; 
        wait (BUSY == 1'b0); #120;
        $finish;
    end
endmodule
