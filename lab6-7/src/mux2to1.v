module mux2to1 #(
    parameter WIDTH = 32
) (
    input  [WIDTH-1:0] s0,      // Input 0
    input  [WIDTH-1:0] s1,      // Input 1
    input              sel,     // Select signal
    output reg [WIDTH-1:0] out      // Output
);
    // TODO: Implement the 2-to-1 multiplexer
    always @(*) begin
        case (sel)
            1'b0: out = s0;  // Select s0
            1'b1: out = s1;  // Select s1
        endcase
    end

endmodule
