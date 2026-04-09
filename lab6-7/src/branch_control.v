module branch_control (
    input  wire [31:0] a,      // Value of register rs1
    input  wire [31:0] b,      // Value of register rs2
    input  wire [ 2:0] ops,    // [Control Signal] Branch type (e.g., BEQ, BNE, BLT, BGE, etc.)
    output reg         branch  // Output signal indicating whether to take the branch or not
);
    // TODO: Implement the branch control
    always @(*) begin
        branch = 1'b0;
        case (ops)
            3'b000: begin
                if (a == b) branch = 1'b1;
            end
            3'b001: begin
                if (a != b) branch = 1'b1;
            end
            3'b100: begin
                if ($signed(a) < $signed(b)) branch = 1'b1;
            end
            3'b101: begin
                if ($signed(a) >= $signed(b)) branch = 1'b1;
            end
            3'b110: begin
                if (a < b) branch = 1'b1;
            end
            3'b111: begin
                if (a >= b) branch = 1'b1;
            end
            default: branch = 1'b0;
        endcase
    end

endmodule
