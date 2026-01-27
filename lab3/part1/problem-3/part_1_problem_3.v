`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 10:46:14 PM
// Design Name: 
// Module Name: part_1_problem_3
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


module part_1_problem_3 (
    input  wire a,
    input  wire b,
    output wire led
);
  // This is an example of constraint file error
  assign led = a & b;
endmodule
