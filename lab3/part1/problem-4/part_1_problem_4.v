`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 10:51:30 PM
// Design Name: 
// Module Name: part_1_problem_4
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


module part_1_problem_4 (
    input wire clk,
    input wire [19:0] address,
    input wire [7:0] din,
    output wire [7:0] dout,
    input wire write_enable
);
  // This is an example of resource overuse error
  reg [7:0] memory_array [0:1048575];  // 1M x 8-bit memory = 1 Gbyte of memory
  reg [7:0] dout_reg = 0;
  always @(posedge clk) begin
    if (write_enable) begin
      memory_array[address] <= din;
    end else begin
      dout_reg <= memory_array[address];
    end
  end
  assign dout = dout_reg;
endmodule
