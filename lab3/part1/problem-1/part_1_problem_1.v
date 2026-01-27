`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 10:26:57 PM
// Design Name: 
// Module Name: part_1_problem_1
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


module part_1_problem_1 (
    input  wire a,
    input  wire b,
    output wire y
);
  // This is an example of the multiple drivers on a single output port
  assign y = a;
  assign y = b;
endmodule
