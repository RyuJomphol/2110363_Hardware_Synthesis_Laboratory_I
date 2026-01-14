module dff_sync_reset (
    input  clk,
    input  rst,
    input  D,
    output reg Q
);
    // TODO: Implement the D flip-flop with synchronous reset behavior here
    always @(posedge clk) begin
        if (rst)
            Q <= 1'b0;   // synchronous reset
        else
            Q <= D;      // latch D on rising edge
    end

endmodule