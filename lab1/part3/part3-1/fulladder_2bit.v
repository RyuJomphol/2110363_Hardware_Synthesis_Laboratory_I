`timescale 1ns / 1ps

module fulladder_2bit (
    input  wire [1:0] A,
    input  wire [1:0] B,
    input  wire       Cin,
    output wire [1:0] Sum,
    output wire       Cout
);
  assign {Cout, Sum} = A + B + Cin;
endmodule
