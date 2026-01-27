`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2026 07:36:00 PM
// Design Name: 
// Module Name: top_module
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


module top_module (
    input wire clk,
    output wire [2:0] processed_data
);

  // This is the fully connected module
  wire [7:0] fully_connected_data;
  producer prod_fully_inst (
      .clk (clk),
      .data(fully_connected_data)
  );
  consumer cons_fully_inst (
      .clk(clk),
      .data(fully_connected_data),
      .processed_data(processed_data[0])
  );

  // This is the partial connected module
  wire [3:0] partial_connected_data;
  producer prod_partial_inst (
      .clk (clk),
      .data(partial_connected_data)
  );
  consumer cons_partial_inst (
      .clk(clk),
      .data(partial_connected_data),
      .processed_data(processed_data[1])
  );

  // This is the not connected module
  wire not_connected_data_0;
  wire not_connected_data_1;
  producer prod_not_connected_inst (
      .clk (clk),
      .data(not_connected_data_0)
  );
  consumer cons_not_connected_inst (
      .clk(clk),
      .data(not_connected_data_1),
      .processed_data(processed_data[1])
  );
endmodule
