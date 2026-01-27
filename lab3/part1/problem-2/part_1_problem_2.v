`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 10:41:54 PM
// Design Name: 
// Module Name: part_1_problem_2
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


module part_1_problem_2 (
    input wire clk,
    input wire enable,
    output wire [3:0] counter
);
  // This is an example of a error where we have a missing module in our design
  missing_module missing_inst (
      .clk(clk),
      .enable(enable),
      .counter(counter)
  );
endmodule
