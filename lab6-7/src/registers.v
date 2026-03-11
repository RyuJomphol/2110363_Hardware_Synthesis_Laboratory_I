// For student: Do not modify this file!

module registers (
    input         clk,         // Clock
    input         rst,         // Active high reset
    input         reg_write,   // Register write signal
    input  [ 4:0] read_reg1,   // Specify register to read (port 1)
    input  [ 4:0] read_reg2,   // Specify register to read (port 2)
    input  [ 4:0] write_reg,   // Specify register to write
    input  [31:0] write_data,  // Value to write to register
    output [31:0] read_data1,  // Value of register at port 1
    output [31:0] read_data2   // Value of register at port 2
);

    reg [31:0] regs[0:31];

    assign read_data1 = regs[read_reg1];
    assign read_data2 = regs[read_reg2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            regs[0]  <= 0;  // x0 is always 0
            regs[1]  <= 0;
            regs[2]  <= 32'd128;
            regs[3]  <= 0;
            regs[4]  <= 0;
            regs[5]  <= 0;
            regs[6]  <= 0;
            regs[7]  <= 0;
            regs[8]  <= 0;
            regs[9]  <= 0;
            regs[10] <= 0;
            regs[11] <= 0;
            regs[12] <= 0;
            regs[13] <= 0;
            regs[14] <= 0;
            regs[15] <= 0;
            regs[16] <= 0;
            regs[17] <= 0;
            regs[18] <= 0;
            regs[19] <= 0;
            regs[20] <= 0;
            regs[21] <= 0;
            regs[22] <= 0;
            regs[23] <= 0;
            regs[24] <= 0;
            regs[25] <= 0;
            regs[26] <= 0;
            regs[27] <= 0;
            regs[28] <= 0;
            regs[29] <= 0;
            regs[30] <= 0;
            regs[31] <= 0;
        end else if (reg_write) regs[write_reg] <= (write_reg == 0) ? 0 : write_data;
    end

endmodule

