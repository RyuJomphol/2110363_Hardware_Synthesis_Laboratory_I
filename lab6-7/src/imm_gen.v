module imm_gen (
    input  wire [31:0] inst,  // Input instruction
    output reg  [31:0] imm    // Output immediate value
);
    // TODO: Implement the immediate generator
    always @(*) begin
        case(inst[6:0])
            //I-type 11:0 (12bit)
            7'b0000011, 7'b0010011, 7'b1100111: begin
                imm = {{20{inst[31]}},inst[31:20]};
            end
            //U-type 31:12 (20bit)
            7'b0010111, 7'b0110111: begin
                imm = {inst[31:12],12'd0};
            end
            //S-type 31:25 11:7
            7'b0100011: begin
                imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
            end
            //B-type 31:25 11:7
            7'b1100011: begin
                imm = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
            end
            //J-type 31:12 (20bit)
            7'b1101111: begin
                imm = {{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; //12:1
            end
            default: imm = 32'd0;
        endcase
    end

endmodule
