`timescale 1ns / 1ps

module counter (
    input wire clk,
    input wire enable,
    input wire reset,
    output wire [1:0] counter_value
);
  reg [1:0] counter_value_reg = 0;

  always @(posedge clk) begin
    if (reset) begin
      counter_value_reg <= 0;
    end else begin
      if (enable) begin
        counter_value_reg <= counter_value_reg + 1;
      end
    end
  end

  assign counter_value = counter_value_reg;
endmodule
