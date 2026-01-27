`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2026 07:37:18 PM
// Design Name: 
// Module Name: consumer
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


module consumer (
    input wire clk,
    input wire [7:0] data,
    output wire processed_data
);

  reg processed_data_reg = 0;
  assign processed_data = processed_data_reg;

  always @(posedge clk) begin
    processed_data_reg <= data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7];
  end
endmodule
