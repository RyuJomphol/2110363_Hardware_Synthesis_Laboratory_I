`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 11:57:34 PM
// Design Name: 
// Module Name: design_under_test_top
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


module design_under_test_top (
    input wire clk
);

    wire       start;
    wire       rst;
    wire [7:0] data_length;
    wire [7:0] data_out;
    wire       data_valid;

    // TODO [Step 3.C]: Instantiate VIO
    vio_data_generator_conf vio_inst (
    .clk       (clk),
    .probe_out0(start),
    .probe_out1(rst),
    .probe_out2(data_length)
    );
    // ----------------------------------

    data_generator dut_inst (
        .clk        (clk),
        .rst        (rst),
        .start      (start),
        .data_length(data_length),
        .data_out   (data_out),
        .data_valid (data_valid)
    );

    // TODO [Step 2.D]: Instantiate ILA
    ila_data_out ila_inst (
    .clk   (clk),
    .probe0(data_out),
    .probe1(data_valid)
    );
    // ----------------------------------

endmodule
