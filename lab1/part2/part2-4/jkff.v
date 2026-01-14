module jkff (
    input  J,
    input  K,
    input  clk,
    output reg Q
);
    // TODO: Implement the JK flip-flop behavior
    always @(posedge clk) begin
        case ({J, K})
            2'b00: Q <= Q;     // Hold
            2'b01: Q <= 1'b0;  // Reset
            2'b10: Q <= 1'b1;  // Set
            2'b11: Q <= ~Q;    // Toggle
        endcase
    end


endmodule
