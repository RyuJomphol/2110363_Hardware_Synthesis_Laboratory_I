module bcd_counter (
    input        clk,
    input        rst,
    output reg [3:0] q,
    output reg      cout
);
    // TODO: Implement BCD counter
    always @(posedge clk) begin
    if (rst) begin
      q    <= 4'd0;
      cout <= 1'b0;
    end else begin
      if (q == 4'd9) begin
        q    <= 4'd0;
        cout <= 1'b0;
      end else if (q == 4'd8) begin
        q    <= 4'd9;
        cout <= 1'b1;
      end else begin
        q    <= q + 4'd1;
        cout <= 1'b0;
      end
    end
  end


endmodule
