`timescale 1ns / 1ps

module debouncer #(
    SAMPLING_RATE = 100000, // 100kHz
    COUNTER_WIDTH = 17      // log2(SAMPLING_RATE) = 17
) (
    input  clk,
    input  data_in,
    output reg data_out
);

    reg [COUNTER_WIDTH-1:0] counter = 0;

    always @(posedge clk) begin
        if (counter < SAMPLING_RATE - 1) begin
            counter <= counter + 1'b1;
        end else begin
            data_out <= data_in;
            counter <= 0;
        end
    end
endmodule
