`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2026 07:36:26 PM
// Design Name: 
// Module Name: producer
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


module producer (
    input wire clk,
    output wire [7:0] data
);
  reg [7:0] data_reg = 0;
  assign data = data_reg;

  always @(posedge clk) begin
    data_reg <= data_reg + 1;
  end
endmodule
