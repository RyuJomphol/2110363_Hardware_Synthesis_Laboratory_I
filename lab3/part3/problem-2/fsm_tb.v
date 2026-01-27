`timescale 1ns / 1ns

module fsm_tb ();
    // Create wires and regs to connect to the DUT
    reg        clk;
    reg        reset;
    reg        data_in;
    wire [1:0] data_out;

    // TODO: instantiate the DUT and write the testbench logic

    // DUT
    fsm dut (
        .clk     (clk),
        .rst     (reset),
        .data_in (data_in),
        .data_out(data_out)
    );

    // Clock: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Apply input for 1 clock cycle
    task apply;
        input din;
        begin
            data_in = din;
            @(posedge clk); #1;
        end
    endtask

    initial begin
        // init
        reset  = 0;
        data_in = 0;

        // synchronous reset
        reset = 1;
        @(posedge clk); #1;
        reset = 0;

        // ---- Force all transitions (including C->B) ----
        apply(1); // A -> B
        apply(1); // B -> C
        apply(1); // C -> B   <<< (เพิ่มให้ครบตามที่ขาด)
        apply(0); // B -> D
        apply(0); // D -> A

        apply(0); // A -> D
        apply(1); // D -> B
        apply(1); // B -> C (ซ้ำได้)
        apply(0); // C -> D
        apply(0); // D -> A

        #10;
        $finish;
    end

    // -- Do not delete the lines below --
    // Dump waveforms
    initial begin
        $dumpfile("fsm_tb.vcd");
        $dumpvars(0, fsm_tb);
    end

endmodule