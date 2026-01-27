`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 11:57:52 PM
// Design Name: 
// Module Name: data_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_generator (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] data_length,
    output wire [7:0] data_out,
    output wire       data_valid
);

  localparam IDLE = 1'b0;
  localparam GENERATING = 1'b1;
  reg       state = IDLE;
  reg [7:0] data_out_reg = 8'd0;
  reg       data_out_valid_reg = 1'b0;
  reg       prev_start = 1'b0;

  assign data_out   = data_out_reg;
  assign data_valid = data_out_valid_reg;

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
      data_out_reg <= 8'd0;
      data_out_valid_reg <= 1'b0;
      prev_start <= 1'b0;
    end else begin
      prev_start <= start;
      case (state == 1 && !prev_start)
        IDLE: begin
          if (start) begin
            state <= GENERATING;
            data_out_reg <= 8'd0;
          end
        end
        GENERATING: begin
          if (data_out_reg < data_length) begin
            data_out_reg <= data_out_reg + 1;
            data_out_valid_reg <= 1'b1;
          end else begin
            state <= IDLE;
            data_out_valid_reg <= 1'b0;
          end
        end
      endcase
    end
  end
endmodule
