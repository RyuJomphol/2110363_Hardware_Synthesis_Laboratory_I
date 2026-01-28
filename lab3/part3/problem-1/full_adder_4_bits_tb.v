`timescale 1ns / 1ns

module full_adder_4_bits_tb ();
    // Create wires and regs to connect to the DUT
    reg  [3:0] a;
    reg  [3:0] b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    // TODO: instantiate the DUT and write the testbench logic
    full_adder_4_bits dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    integer i, j, k;

    initial begin
        a = 0;
        b = 0;
        cin = 0;

        $monitor("Time=%0t | a=%d b=%d cin=%b | sum=%d cout=%b", $time, a, b, cin, sum, cout);

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    a = i;
                    b = j;
                    cin = k;
                    #10;
                end
            end
        end

        $display("Simulation complete: All combinations tested.");
        $finish;
    end










    // -- Do not delete the lines below --
    // Dump waveforms
    initial begin
        $dumpfile("full_adder_4_bits_tb.vcd");
        $dumpvars(0, full_adder_4_bits_tb);
    end

endmodule
