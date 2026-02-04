`timescale 1ns / 1ps

module ram_wrapper_tb ();

    // Inputs
    reg         clk;
    reg         ena;
    reg         wea;
    reg  [ 7:0] addr;
    reg  [15:0] din;

    // Outputs
    wire [15:0] dout;

    // Instantiate the Unit Under Test (UUT)
    ram_wrapper uut (
        .clk (clk),
        .ena (ena),
        .wea (wea),
        .addr(addr),
        .din (din),
        .dout(dout)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50MHz clock
    end

    initial begin
        // Initialize Inputs
        clk  = 0;
        ena  = 0;
        wea  = 0;
        addr = 0;
        din  = 0;

        #20;

        // Write data to RAM at address 0x10
        ena  = 1;
        wea  = 1;
        addr = 8'h10;
        din  = 16'hABCD;
        #20;

        // Write data to RAM at address 0x11
        addr = 8'h11;
        din  = 16'h1234;
        #20;

        // Read data from RAM at address 0x10
        wea  = 0;
        addr = 8'h10;
        #20;

        // Read data from RAM at address 0x11
        addr = 8'h11;
        #20;

        // Write data to RAM at address 0x12
        wea  = 1;
        addr = 8'h12;
        din  = 16'h2222;
        #20;

        // Write data to RAM at address 0x11
        addr = 8'h11;
        din  = 16'h3333;
        #20;

        // Read data from RAM at address 0x12
        wea  = 0;
        addr = 8'h12;
        #20;

        // Read data from RAM at address 0x11
        addr = 8'h11;
        #20;

        $finish;

    end



endmodule
