module lfsr_16 (
    input wire clk,
    input wire reset,
    input wire enable,
    output wire [15:0] lfsr_out
);

    // สร้าง register ภายในเพื่อเก็บสถานะของ LFSR
    reg [15:0] current_state;

    // เชื่อมต่อ output กับ register ภายใน [cite: 38]
    assign lfsr_out = current_state;

    // การทำงานของ LFSR ที่ขอบขาขึ้นของ clock [cite: 51]
    always @(posedge clk) begin
        if (reset) begin
            // 1. Synchronous Reset: กำหนดค่าเริ่มต้นเป็น 16'hFFFF 
            current_state <= 16'hFFFF;
        end 
        else if (enable) begin
            // 2. Enable Control: ทำงานเมื่อ enable เป็น high เท่านั้น [cite: 37, 52]
            // Tap Selection: เลือกบิทที่ 4, 13, 15, และ 16 (เทียบเท่า index 3, 12, 14, 15) 
            // Logic: Feedback = S4 ^ S13 ^ S15 ^ S16
            // เลื่อนบิทไปทางขวา (S1 -> S2 -> ... -> S16) และรับ Feedback เข้าที่ S1 (lfsr_out[0])
            current_state <= {current_state[14:0], (current_state[3] ^ current_state[12] ^ current_state[14] ^ current_state[15])};
        end
        // 3. ถ้า enable เป็น low ให้คงค่าเดิมไว้ (Implicit Hold) 
    end

`ifdef COCOTB_SIM
  initial begin
    $dumpfile("waveform.vcd");  // Name of the dump file
    $dumpvars(0, lfsr_16);  // Dump all variables for the top module
  end
`endif

endmodule