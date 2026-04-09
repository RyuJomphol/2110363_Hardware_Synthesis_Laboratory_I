module single_cycle_cpu_lab7 (
    input  wire       clk,     // Clock signal
    input  wire       rst,     // Active high synchronous reset signal
    // input  wire [9:0] testcase_id,  // Test case ID for testing purposes
    input  wire [7:0] sw,      // (Lab 7) Memory-mapped I/O switches
    output wire [7:0] led,     // (Lab 7) Memory-mapped I/O LEDs
    input  wire       uart_rx  // (Lab 7) for UART receive data
);

  wire [31:0] pc;  // Program Counter
  wire [31:0] next_pc;  // Next value of the Program Counter
  wire [31:0] inst;  // Current instruction
  wire [31:0] imm;  // Immediate value generated from the instruction

  wire [31:0] normal_next_pc;  // Next PC for normal instructions (PC + 4)

  // Instruction funct
  wire [ 6:0] opcode;
  wire [ 2:0] funct3;
  wire [ 6:0] funct7;

  wire [31:0] read_data1;  // Data read from register file (port 1)
  wire [31:0] read_data2;  // Data read from register file (port 2)

  wire [31:0] alu_src_1;  // First operand for ALU
  wire [31:0] alu_src_2;  // Second operand for ALU
  wire [31:0] alu_result;  // Result from ALU

  // Control signals
  wire        mem_read;  // Memory read control signal
  wire        mem_write;  // Memory write control signal
  wire [ 2:0] data_mask;  // Data mask for memory operations
  wire        reg_write;  // Register write control signal
  wire        alu_src_1_sel;  // ALU source select for operand 1
  wire        alu_src_2_sel;  // ALU source select for operand 2
  wire [ 3:0] alu_control;  // ALU control signal
  wire [ 1:0] write_to_reg_sel;  // Control signal for MUX
  wire [ 2:0] branch_type;  // Branch type control signal
  wire        is_branch;  // Signal indicating if the instruction is a branch
  wire        is_jump;  // Signal indicating if the instruction is a jump


  // mem
  wire [31:0] mem_read_data;  // Data read from memory

  // write back
  wire [31:0] write_back_data;  // Data to be written back to register file

  // branch taken
  wire        branch_taken;

  // soft reset for instruction whole system reset when uart receives specific command
  wire        soft_reset;
  wire        sys_reset;
  assign sys_reset = rst | soft_reset;  // System reset is active when either rst or soft_reset is active

  assign opcode = inst[6:0];
  assign funct3 = inst[14:12];
  assign funct7 = inst[31:25];


  pc pc_inst (
      .clk       (clk),
      .rst       (sys_reset),  // Reset PC on reset or soft reset
      .next_pc   (next_pc),
      .current_pc(pc)
  );

  adder pc_adder_inst (
      .a  (pc),
      .b  (32'd4),
      .sum(normal_next_pc)
  );

  instruction_memory_lab7 imem_inst (
      .clk       (clk),
      .uart_rx   (uart_rx),
      .rst       (rst),
      .soft_reset(soft_reset),
      .read_addr (pc),
      .inst      (inst)
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
      .rst       (sys_reset),
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
      .rst       (sys_reset),
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
      .s2 (normal_next_pc),    // For JAL instruction, write PC + 4 to rd
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
