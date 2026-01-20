module full_adder_4_bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire cin,
    output wire [3:0] sum,
    output wire cout
);
    // TODO: Implement the 4-bit full adder here
    wire [4:0] tmp;

    assign tmp  = {1'b0, a} + {1'b0, b} + cin;
    assign sum  = tmp[3:0];
    assign cout = tmp[4];

    
endmodule