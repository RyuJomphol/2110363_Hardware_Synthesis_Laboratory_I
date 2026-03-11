// For student: Do not modify this file except memory initialization file!

module instruction_memory (
    input  wire [31:0] read_addr,  // Address to read (usually is PC)
    output wire [31:0] inst        // Instruction that is read
);

    reg [7:0] insts[127:0];

    assign inst = (read_addr >= 32'd128) ? 32'b0 : {insts[read_addr], insts[read_addr + 1], insts[read_addr + 2], insts[read_addr + 3]};

    initial begin
        insts[0]  = 8'b0;
        insts[1]  = 8'b0;
        insts[2]  = 8'b0;
        insts[3]  = 8'b0;
        insts[4]  = 8'b0;
        insts[5]  = 8'b0;
        insts[6]  = 8'b0;
        insts[7]  = 8'b0;
        insts[8]  = 8'b0;
        insts[9]  = 8'b0;
        insts[10] = 8'b0;
        insts[11] = 8'b0;
        insts[12] = 8'b0;
        insts[13] = 8'b0;
        insts[14] = 8'b0;
        insts[15] = 8'b0;
        insts[16] = 8'b0;
        insts[17] = 8'b0;
        insts[18] = 8'b0;
        insts[19] = 8'b0;
        insts[20] = 8'b0;
        insts[21] = 8'b0;
        insts[22] = 8'b0;
        insts[23] = 8'b0;
        insts[24] = 8'b0;
        insts[25] = 8'b0;
        insts[26] = 8'b0;
        insts[27] = 8'b0;
        insts[28] = 8'b0;
        insts[29] = 8'b0;
        insts[30] = 8'b0;
        insts[31] = 8'b0;

        // You may want to change the name of the file to read
        $readmemb("EXAMPLE_INSTRUCTIONS.mem", insts);
    end

endmodule

