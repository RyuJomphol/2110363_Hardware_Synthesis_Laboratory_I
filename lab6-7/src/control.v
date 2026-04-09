module control (
    input wire [6:0] opcode,  // Opcode from the instruction
    input wire [2:0] funct3,  // funct3 field from the instruction
    input wire [6:0] funct7,  // funct7 field from the instruction
    output reg mem_read,  // Memory read control signal
    output reg mem_write,  // Memory write control signal
    output reg [2:0] data_mask,  // Memory data mask control signal (indicates how many bytes to read/write and whether it's signed/unsigned, usually derived from funct3)
    output reg reg_write,  // Register write control signal
    output reg alu_src_1,  // ALU source select control signal 1 (0 = from rs1, 1 = from PC)
    output reg alu_src_2,  // ALU source select control signal 2 (0 = from rs2, 1 = from immediate)
    output reg [3:0] alu_control,  // ALU control signal
    output reg [1:0] write_to_reg_sel,    // Control signal for MUX which selects data to write back to register (0 = from ALU, 1 = from memory, 2 = from PC + 4)
    output reg [2:0] branch_type,  // Control signal for branch type (derived from funct3 for B-type instructions, can be used to determine the type of branch condition to check)
    output reg is_branch,    // Control signal indicating whether the instruction is a branch (can be used to control PC update logic
    output reg is_jump     // Control signal indicating whether the instruction is a jump (e.g., JAL, JALR)
);
    // TODO: Implement the control logic
    always @(*) begin
        mem_read = 1'b0;
        mem_write = 1'b0;
        data_mask = 3'b000;
        reg_write = 1'b0;
        alu_src_1 = 1'b0;
        alu_src_2 = 1'b0;
        alu_control = 4'b0000;
        write_to_reg_sel = 2'b00;
        branch_type = 3'b000;
        is_branch = 1'b0;
        is_jump = 1'b0;

        case (opcode)
            7'b0000011: begin // I Load
                mem_read = 1'b1;
                data_mask = funct3;
                reg_write = 1'b1;
                alu_src_2 = 1'b1;
                write_to_reg_sel = 2'b01;
            end
            7'b0010011: begin // I Operation
                reg_write = 1'b1;
                alu_src_2 = 1'b1;
                case(funct3)
                    3'b000 : alu_control = 4'b0000;
                    3'b001 : alu_control = 4'b0001;
                    3'b010 : alu_control = 4'b0010;
                    3'b011 : alu_control = 4'b0011;
                    3'b100 : alu_control = 4'b0100;
                    3'b101 : begin
                        if(funct7[5]) alu_control = 4'b1101;
                        else alu_control = 4'b0101;
                    end 
                    3'b110 : alu_control = 4'b0110;
                    3'b111 : alu_control = 4'b0111;
                endcase
            end
            7'b0010111: begin // U Add
                reg_write = 1'b1;
                alu_src_1 = 1'b1;
                alu_src_2 = 1'b1;
            end
            7'b0100011: begin // S
                mem_write = 1'b1;
                data_mask = funct3;
                alu_src_2 = 1'b1;
            end
             7'b0110011: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000 : alu_control = (funct7[5]) ? 4'b1000 : 4'b0000; //sub : add
                    3'b001 : alu_control = 4'b0001; //sll
                    3'b010 : alu_control = 4'b0010; //slt
                    3'b011 : alu_control = 4'b0011; //sltu
                    3'b100 : alu_control = 4'b0100; //xor
                    3'b101 : alu_control = (funct7[5]) ? 4'b1101 : 4'b0101; //sra : srl
                    3'b110 : alu_control = 4'b0110; //or
                    3'b111 : alu_control = 4'b0111; //and
                endcase
            end
            7'b0110111: begin // U Load
                reg_write = 1'b1;
                alu_src_2 = 1'b1;
                alu_control = 4'b1111;
            end
            7'b1100011: begin // B
                alu_src_1 = 1'b1;
                alu_src_2 = 1'b1;
                branch_type = funct3;
                is_branch = 1'b1;
            end
            7'b1100111: begin // I jump
                reg_write = 1'b1;
                alu_src_2 = 1'b1;
                write_to_reg_sel = 2'b10;
                is_jump = 1'b1;
            end
            7'b1101111: begin // J
                reg_write = 1'b1;
                alu_src_1 = 1'b1;
                alu_src_2 = 1'b1;
                write_to_reg_sel = 2'b10;
                is_jump = 1'b1;
            end
        endcase
    end
endmodule
