module adder #(
    WIDTH = 32
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] sum
);
    // TODO: Implement the adder
    assign sum = a + b;

endmodule
