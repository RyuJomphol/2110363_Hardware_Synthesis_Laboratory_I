module debouncer #(
    parameter SAMPLING_RATE = 3,
    parameter COUNTER_WIDTH = 2
) (
    input clk,
    input rst,
    input data_in,
    output reg data_out
);

  reg [COUNTER_WIDTH-1:0] c;

  always @(posedge clk) begin
    if (rst) begin
      c        <= 0;
      data_out <= 0;
    end else begin
      if (c == SAMPLING_RATE - 1) begin
        data_out <= data_in;
        c        <= 0;
      end else begin
        c <= c + 1;
      end
    end
  end

endmodule
