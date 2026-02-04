`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 10:14:08 PM
// Design Name: 
// Module Name: fifo_controller
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


module fifo_controller(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [7:0] din,
    output [7:0] dout,
    output full,
    output empty,
    output reg [3:0] occupancy_count
    );

    reg [2:0] write_index;
    reg [2:0] read_index;

    assign full = (occupancy_count == 8);
    assign empty = (occupancy_count == 0);

    blk_mem_ram fifo_ram (
        .clka(clk),
        .wea(wr_en && !full),
        .addra(write_index),
        .dina(din),
        .clkb(clk),
        .addrb(read_index),
        .doutb(dout)
    );

    always @(posedge clk ) begin
        if (rst) begin
            read_index <= 0;
            write_index <= 0;
            occupancy_count <= 0;
        end else begin
            if (wr_en && !full) begin
                write_index <= write_index + 1;
            end

            if (rd_en && !empty) begin
                read_index <= read_index + 1;
            end

            // Ensure count start the same if the both read and write at the same time
            if ((wr_en && !full) && !(rd_en && !empty)) begin
                occupancy_count <= occupancy_count + 1;
            end else if ((rd_en && !empty) && !(wr_en && !full)) begin
                occupancy_count <= occupancy_count - 1;
            end
        end
    end
endmodule
