`timescale 1ns / 1ps

module rom_tb ();

    reg        clk;
    reg  [3:0] in;
    wire [7:0] out;

    rom uut (
        .clk(clk),
        .in (in),
        .out(out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period
    end

    initial begin

        for (integer i = 0; i < 16; i = i + 1) begin
            in = i;
            #10;  // Wait for one clock cycle
            $display("Input: %d, Output: %d", in, out);
        end
        #10;
        $finish;
    end

endmodule
