module single_cycle_cpu (
    input  wire       clk,          // Clock signal
    input  wire       rst,          // Active high synchronous reset signal
    input  wire [9:0] testcase_id,  // Test case ID for testing purposes
    input  wire [7:0] sw,           // (Lab 7) Memory-mapped I/O switches
    output wire [7:0] led           // (Lab 7) Memory-mapped I/O LEDs
);

    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] inst;
    wire [31:0] imm;

    wire [31:0] normal_next_pc;

    // Instruction funct
    wire [ 6:0] opcode;
    wire [ 2:0] funct3;
    wire [ 6:0] funct7;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] alu_src_1;
    wire [31:0] alu_src_2;
    wire [31:0] alu_result;

    // Control signals
    wire        mem_read;
    wire        mem_write;
    wire [ 2:0] data_mask;
    wire        reg_write;
    wire        alu_src_1_sel;
    wire        alu_src_2_sel;
    wire [ 3:0] alu_control;
    wire [ 1:0] write_to_reg_sel;
    wire [ 2:0] branch_type;
    wire        is_branch;
    wire        is_jump;


    // mem
    wire [31:0] mem_read_data;

    // write back
    wire [31:0] write_back_data;

    // branch taken
    wire        branch_taken;

    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];

    pc pc_inst (
        .clk       (clk),
        .rst       (rst),
        .next_pc   (next_pc),
        .current_pc(pc)
    );

    adder pc_adder_inst (
        .a  (pc),
        .b  (32'd4),
        .sum(normal_next_pc)
    );

    instruction_memory imem_inst (
        .read_addr(pc),
        .inst     (inst)
    );

    imm_gen imm_gen_inst (
        .inst(inst),
        .imm (imm)
    );

    control control_inst (
        .opcode          (opcode),
        .funct3          (funct3),
        .funct7          (funct7),
        .mem_read        (mem_read),
        .mem_write       (mem_write),
        .data_mask       (data_mask),
        .reg_write       (reg_write),
        .alu_src_1       (alu_src_1_sel),
        .alu_src_2       (alu_src_2_sel),
        .alu_control     (alu_control),
        .write_to_reg_sel(write_to_reg_sel),
        .branch_type     (branch_type),
        .is_branch       (is_branch),
        .is_jump         (is_jump)
    );

    registers registers_inst (
        .clk       (clk),
        .rst       (rst),
        .reg_write (reg_write),
        .read_reg1 (inst[19:15]),
        .read_reg2 (inst[24:20]),
        .write_reg (inst[11:7]),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    mux2to1 alu_src_1_mux (
        .sel(alu_src_1_sel),
        .s0 (read_data1),
        .s1 (pc),
        .out(alu_src_1)
    );

    mux2to1 alu_src_2_mux (
        .sel(alu_src_2_sel),
        .s0 (read_data2),
        .s1 (imm),
        .out(alu_src_2)
    );

    alu alu_inst (
        .a          (alu_src_1),
        .b          (alu_src_2),
        .alu_control(alu_control),
        .result     (alu_result)
    );

    data_memory dmem_inst (
        .clk       (clk),
        .rst       (rst),
        .mem_write (mem_write),
        .mem_read  (mem_read),
        .address   (alu_result),
        .write_data(read_data2),
        .data_mask (data_mask),
        .read_data (mem_read_data),
        .sw        (sw),
        .led       (led)
    );

    mux3to1 write_to_reg_mux (
        .sel(write_to_reg_sel),
        .s0 (alu_result),
        .s1 (mem_read_data),
        .s2 (normal_next_pc),
        .out(write_back_data)
    );

    mux2to1 next_pc_mux (
        .sel((branch_taken & is_branch) | is_jump),
        .s0 (normal_next_pc),
        .s1 (alu_result),
        .out(next_pc)
    );

    branch_control branch_control_inst (
        .a     (read_data1),
        .b     (read_data2),
        .ops   (branch_type),
        .branch(branch_taken)
    );


endmodule
