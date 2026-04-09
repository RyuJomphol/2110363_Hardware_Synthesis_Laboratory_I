module prob3 (
    input wire clk,
    input wire reset,
    input wire inp,
    output wire out
);

    // reg [4:0] yeen_state;
    // reg ans;
    // assign out = ans;

    // always @(posedge clk) begin
    //   if (reset) begin
    //     yeen_state <= 5'b00001;
    //     ans <= 0;
    //   end
    //   else begin
    //     case (yeen_state)
    //       5'b00001 : begin
    //         if (inp == 0) begin
    //           yeen_state <= 5'b00001;
    //         end
    //         else begin
    //           yeen_state <= 5'b00010;
    //         end
    //       end
    //       5'b00010 : begin
    //         if (inp == 0) begin
    //           yeen_state <= 5'b00011;
    //         end
    //         else begin
    //           yeen_state <= 5'b00100;
    //         end
    //       end
    //       5'b00011 : begin
    //         if (inp == 0) begin
    //           yeen_state <= 5'b00001;
    //         end
    //         else begin
    //           yeen_state <= 5'b00100;
    //         end
    //       end
    //       5'b00100 : begin
    //         if (inp == 0) begin
    //           yeen_state <= 5'b00101;
    //         end
    //         else begin
    //           yeen_state <= 5'b00100;
    //         end
    //       end
    //       5'b00101 : begin
    //         if (inp == 0) begin
    //           yeen_state <= 5'b00100;
    //         end
    //         else begin
    //           yeen_state <= 5'b00001;
    //         end
    //       end
    //     endcase
    //   end
    // end

    // always @(*) begin
    //   case (yeen_state)
    //     5'b00001 : begin
    //      if (inp == 0) begin
    //        ans <= 0;
    //       end
    //       else begin
    //         ans <= 1;
    //       end
    //     end
    //     5'b00010 : begin
    //       if (inp == 0) begin
    //         ans <= 0;
    //       end
    //       else begin
    //         ans <= 1;
    //       end
    //     end
    //     5'b00011 : begin
    //       if (inp == 0) begin
    //         ans <= 0;
    //       end
    //       else begin
    //         ans <= 0;
    //       end
    //     end
    //     5'b00100 : begin
    //       if (inp == 0) begin
    //         ans <= 0;
    //       end
    //       else begin
    //         ans <= 1;
    //       end
    //     end
    //     5'b00101 : begin
    //       if (inp == 0) begin
    //         ans <= 1;
    //        end
    //       else begin
    //         ans <= 0;
    //       end
    //     end
    //   endcase
    // end
  `ifdef COCOTB_SIM
    initial begin
      $dumpfile("waveform.vcd");  // Name of the dump file
      $dumpvars(0, prob3);  // Dump all variables for the top module
    end
  `endif

    reg [2:0] state;

    always @ (posedge clk) begin
      if (reset) begin
        state <= 3'b001;
      end else begin
        case(state)
          3'b001 : state <= (inp == 0) ? 3'b001 : 3'b010;
          3'b010 : state <= (inp == 0) ? 3'b011 : 3'b100;
          3'b011 : state <= (inp == 0) ? 3'b001 : 3'b100;
          3'b100 : state <= (inp == 0) ? 3'b101 : 3'b100;
          3'b101 : state <= (inp == 0) ? 3'b100 : 3'b001;
        endcase
      end
    end

    reg tmp;
    assign out = tmp;

    always @ (*) begin
      case(state)
        3'b001 : tmp <= (inp == 0) ? 0 : 1;
        3'b010 : tmp <= (inp == 0) ? 0 : 1;
        3'b011 : tmp <= (inp == 0) ? 0 : 0;
        3'b100 : tmp <= (inp == 0) ? 0 : 1;
        3'b101 : tmp <= (inp == 0) ? 1 : 0;
        default : tmp <= 0;
      endcase
    end

endmodule