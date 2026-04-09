module alu (
    input  wire [31:0] a,            // First operand
    input  wire [31:0] b,            // Second operand
    input  wire [ 3:0] alu_control,  // [Control Signal] ALU control signal
    output reg  [31:0] result        // ALU result
);
    // TODO: Implement the ALU
    always @(*) begin
        case (alu_control)
            4'b0000: result = a + b;
            4'b0001: result = a << b[4:0];
            4'b0010: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'b0011: result = (a < b) ? 32'd1 : 32'd0;
            4'b0100: result = a ^ b;
            4'b0101: result = a >> b[4:0];
            4'b0110: result = a | b;
            4'b0111: result = a & b;
            4'b1000: result = a - b;
            4'b1101: result = $signed(a) >>> b[4:0];
            4'b1111: result = b;
            default: result = 32'd0;
        endcase
    end


endmodule
