`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 10:29:02 PM
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


module top_module(
    input clk,
    input btnC,
    input btnL,
    input btnR,
    input [7:0] sw,
    output [1:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp
);
    wire rst_db, rst_pulse;
    wire push_db, push_pulse;
    wire pop_db, pop_pulse;

    wire [7:0] fifo_dout;
    wire [3:0] fifo_size;
    wire full;
    wire empty;

    reg [7:0] displayed_data;

    parameter DEBOUNCE_SAMPLING_RATE = 100000;
    parameter DEBOUNCE_COUNTER_WIDTH = 20;


    debouncer# (.SAMPLING_RATE(DEBOUNCE_SAMPLING_RATE), .COUNTER_WIDTH(DEBOUNCE_COUNTER_WIDTH)) reset_debouncer(
        .clk(clk),
        .rst(1'b0),
        .data_in(btnC),
        .data_out(rst_db)
    );

    single_pulser reset_pulser (
        .clk(clk),
        .rst(1'b0),
        .in(rst_db),
        .out(rst_pulse)
    );

    debouncer# (.SAMPLING_RATE(DEBOUNCE_SAMPLING_RATE), .COUNTER_WIDTH(DEBOUNCE_COUNTER_WIDTH)) push_debouncer(
        .clk(clk),
        .rst(rst_pulse),
        .data_in(btnL),
        .data_out(push_db)
    );

    single_pulser push_pulser (
        .clk(clk),
        .rst(rst_pulse),
        .in(push_db),
        .out(push_pulse)
    );

    debouncer #(.SAMPLING_RATE(DEBOUNCE_SAMPLING_RATE), .COUNTER_WIDTH(DEBOUNCE_COUNTER_WIDTH)) pop_debouncer (
        .clk(clk),
        .rst(rst_pulse),
        .data_in(btnR),
        .data_out(pop_db)
    );

    single_pulser pop_pulser (
        .clk(clk),
        .rst(rst_pulse),
        .in(pop_db),
        .out(pop_pulse)
    );

    fifo_controller my_fifo (
        .clk(clk),
        .rst(rst_pulse),
        .wr_en(push_pulse),
        .rd_en(pop_pulse),
        .din(sw),
        .dout(fifo_dout),
        .full(full),
        .empty(empty),
        .occupancy_count(fifo_size)
    );

    assign led[0] = full;
    assign led[1] = empty;

    always @(posedge clk) begin
        if (rst_pulse) begin
            displayed_data <= 8'b00000000;
        end else if (pop_pulse && !empty) begin
            displayed_data <= fifo_dout;
        end
    end

    assign dp = 1'b1;
    seven_seg_controller display_driver (
        .Clk(clk),
        .Reset(rst_db),
        .Digit_1_Value(displayed_data[7:4]),
        .Digit_2_Value(displayed_data[3:0]),
        .Digit_3_Value(4'b0000),
        .Digit_4_Value(fifo_size),
        .AN(an),
        .Display(seg)
    );

endmodule
