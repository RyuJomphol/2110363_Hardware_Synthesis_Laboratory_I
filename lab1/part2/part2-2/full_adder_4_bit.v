module full_adder_4_bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire cin,
    output wire [3:0] sum,
    output wire cout
);
    // TODO: Implement the 4-bit full adder here
    wire c1, c2, c3;

    // bit 0 (LSB)
    assign sum[0] = a[0] ^ b[0] ^ cin;
    assign c1     = (a[0] & b[0]) | (a[0] & cin) | (b[0] & cin);

    // bit 1
    assign sum[1] = a[1] ^ b[1] ^ c1;
    assign c2     = (a[1] & b[1]) | (a[1] & c1) | (b[1] & c1);

    // bit 2
    assign sum[2] = a[2] ^ b[2] ^ c2;
    assign c3     = (a[2] & b[2]) | (a[2] & c2) | (b[2] & c2);

    // bit 3 (MSB)
    assign sum[3] = a[3] ^ b[3] ^ c3;
    assign cout   = (a[3] & b[3]) | (a[3] & c3) | (b[3] & c3);

    
endmodule