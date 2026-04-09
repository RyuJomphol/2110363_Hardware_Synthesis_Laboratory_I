module prob3 (
    input wire clk,
    input wire reset,
    input wire inp,
    output wire out
);

    reg [4:0] yeen_state;
    reg ans;
    assign out = ans;

    always @(posedge clk) begin
      if (reset) begin
        yeen_state <= 5'b00001;
        ans <= 0;
      end
      else begin
        case (yeen_state)
          5'b00001 : begin
            if (inp == 0) begin
              yeen_state <= 5'b00001;
            end
            else begin
              yeen_state <= 5'b00010;
            end
          end
          5'b00010 : begin
            if (inp == 0) begin
              yeen_state <= 5'b00011;
            end
            else begin
              yeen_state <= 5'b00100;
            end
          end
          5'b00011 : begin
            if (inp == 0) begin
              yeen_state <= 5'b00001;
            end
            else begin
              yeen_state <= 5'b00100;
            end
          end
          5'b00100 : begin
            if (inp == 0) begin
              yeen_state <= 5'b00101;
            end
            else begin
              yeen_state <= 5'b00100;
            end
          end
          5'b00101 : begin
            if (inp == 0) begin
              yeen_state <= 5'b00100;
            end
            else begin
              yeen_state <= 5'b00001;
            end
          end
        endcase
      end
    end

    always @(*) begin
      case (yeen_state)
        5'b00001 : begin
         if (inp == 0) begin
           ans <= 0;
          end
          else begin
            ans <= 1;
          end
        end
        5'b00010 : begin
          if (inp == 0) begin
            ans <= 0;
          end
          else begin
            ans <= 1;
          end
        end
        5'b00011 : begin
          if (inp == 0) begin
            ans <= 0;
          end
          else begin
            ans <= 0;
          end
        end
        5'b00100 : begin
          if (inp == 0) begin
            ans <= 0;
          end
          else begin
            ans <= 1;
          end
        end
        5'b00101 : begin
          if (inp == 0) begin
            ans <= 1;
           end
          else begin
            ans <= 0;
          end
        end
      endcase
    end

`ifdef COCOTB_SIM
  initial begin
    $dumpfile("waveform.vcd");  // Name of the dump file
    $dumpvars(0, prob3);  // Dump all variables for the top module
  end
`endif

endmodule
