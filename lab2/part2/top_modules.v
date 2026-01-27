`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2026 01:33:54 PM
// Design Name: 
// Module Name: top_modules
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


module top_modules(
    input clk,
    input btnC,
    input [15:0] sw,
    output reg [3:0] an,
    output [6:0] seg,
    output dp
    );
    
    reg [16:0] slow_clock_counter = 0;
    reg slow_clock = 0;
    
    assign dp = 1;
    
    always @(posedge clk) begin
        slow_clock_counter <= slow_clock_counter + 1;
        if (slow_clock_counter == 0) slow_clock <= ~slow_clock;
    end
    
    reg [1:0] counter = 0;

    always @(posedge slow_clock) begin
      if (btnC) counter <= 0;
      else counter <= counter + 1;
    end
    
    reg [3:0] digit;
    
    always @(*) begin
        case (counter)
            2'd0: begin
                digit = sw[15:12];
                an    = 4'b0111;
            end
            2'd1: begin
                digit = sw[11:8];
                an    = 4'b1011;
            end
            2'd2: begin
                digit = sw[7:4];
                an    = 4'b1101;
            end
            2'd3: begin
                digit = sw[3:0];
                an    = 4'b1110;
            end
            default: begin
                digit = 4'b0000;
                an    = 4'b1111;
            end
        endcase
    end
    
    seven_segment seg_inst (
      .in (digit),
      .out(seg)
  );
    
endmodule
