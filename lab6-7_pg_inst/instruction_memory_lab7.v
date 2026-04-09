// For student: Do not modify this file except memory initialization file!

module instruction_memory_lab7 (
    input  wire        clk,
    input  wire        uart_rx,
    input  wire        rst,
    output wire        soft_reset,
    input  wire [31:0] read_addr,   // Address to read (usually is PC)
    output wire [31:0] inst         // Instruction that is read
);

  reg [7:0] insts[127:0];

  assign inst = (read_addr >= 32'd128) ? 32'b0 : {insts[read_addr], insts[read_addr + 1], insts[read_addr + 2], insts[read_addr + 3]};

  integer i;
  initial begin
    for (i = 0; i < 128; i = i + 1) begin
      insts[i] = 8'b0;
    end
  end

  wire [7:0] uart_data_out;
  wire       uart_data_valid;

  uart_rx uart_rx_inst (
      .clk       (clk),
      .rst       (rst),
      .rx        (uart_rx),
      .data_out  (uart_data_out),
      .data_valid(uart_data_valid)
  );

  localparam IDLE = 4'd0;
  localparam WAIT_FOR_DATA = 4'd1;
  localparam RESET = 4'd2;
  reg [3:0] state = IDLE;

  reg [6:0] stored_addr = 0;  // To store the address from the header
  reg [2:0] counter = 0;
  reg       soft_reset_reg = 1'b0;

  assign soft_reset = soft_reset_reg;

  // header = [ opcode 1 bit | 7 bits of address ]
  // valid address header = {0 , address}
  // valid reset header = {1 , 7'b0} magic number 0x80

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
      stored_addr <= 7'b0;
      counter <= 3'b0;
      soft_reset_reg <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          soft_reset_reg <= 1'b0;  // Clear soft reset in IDLE state
          if (uart_data_valid) begin
            if (uart_data_out[7] == 1'b1) begin  // Check if MSB is 1 for reset command
              soft_reset_reg <= 1'b1;  // Assert soft reset
              counter <= 0;
              state <= RESET;  // Transition to RESET state
            end else begin
              stored_addr <= uart_data_out[6:0];  // Store the address (ignore the MSB)
              state <= WAIT_FOR_DATA;  // Transition to wait for header if it's not a reset command
            end
          end
        end
        WAIT_FOR_DATA: begin
          if (uart_data_valid) begin
            insts[stored_addr] <= uart_data_out;  // Store data byte in instruction memory
            state <= IDLE;
          end
        end
        RESET: begin
          if(counter < 3'b111) begin
            counter <= counter + 1'b1;  // Wait for a few cycles to ensure the reset is registered
          end else begin
            soft_reset_reg <= 1'b0;  // Clear soft reset after waiting
            state <= IDLE;  // Transition back to IDLE state
          end
        end
      endcase
    end
  end

endmodule

module uart_rx (
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output wire [7:0] data_out,
    output wire       data_valid
);
  localparam IDLE = 4'd0;
  localparam UART_INCOMING = 4'd1;
  localparam DATA_OUT = 4'd2;
  reg [3:0] state = IDLE;
  reg [9:0] shift_reg = 10'b0;  // Start bit + 8 data bits + Stop bit
  reg [3:0] bit_count = 4'b0;
  reg [9:0] pulse_counter = 10'b0;  // Counter for timing the bits
  reg data_valid_reg = 1'b0;

  assign data_out   = shift_reg[8:1];  // Data bits are in the middle of the shift register
  assign data_valid = data_valid_reg;

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
      shift_reg <= 10'b0;
      bit_count <= 4'b0;
      pulse_counter <= 10'b0;
      data_valid_reg <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          data_valid_reg <= 1'b0;  // Clear data valid in IDLE state
          if (rx == 1'b0) begin  // Start bit detected
            state <= UART_INCOMING;
            shift_reg <= 10'b0;  // Clear shift register for new data
            bit_count <= 4'b0;  // Reset bit count
            pulse_counter <= 10'b0;  // Reset pulse counter
          end
        end
        UART_INCOMING: begin
          if(pulse_counter < 10'd86) begin  // Wait for the full bit period (assuming 100MHz clock and 115200 baud rate
            pulse_counter <= pulse_counter + 1'b1;
            if (pulse_counter == 10'd43) begin  // Sample at the middle of the bit period
              shift_reg <= {rx, shift_reg[9:1]};  // Shift in the new bit
            end
          end else begin
            pulse_counter <= 10'b0;  // Reset pulse counter after full bit period
            if (bit_count == 4'd9) begin
              state <= IDLE;
              data_valid_reg <= 1'b1;  // Set data valid when all bits are received
              bit_count <= 4'b0;  // Reset bit count for next reception
            end else begin
              bit_count <= bit_count + 1'b1;  // Increment bit count
            end
          end
        end
      endcase
    end
  end
endmodule
