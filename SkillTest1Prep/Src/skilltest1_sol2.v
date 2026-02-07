`timescale 1ns / 1ps

module skilltest1_sol2 (
    input  wire       Clk,
    input  wire       Reset,
    input  wire [3:0] Trigger,
    output wire [3:0] BCD0,
    output wire [3:0] BCD1,
    output wire [3:0] BCD2,
    output wire [3:0] BCD3
);

    // ==========================================
    // Internal Registers and Constants
    // ==========================================

    // Main value register (Max 9999 fits in 14 bits: 2^14 = 16384)
    reg [13:0] current_val;
    reg        overflow_active;

    // Debounce Logic Signals
    // We need independent debounce logic for each of the 4 trigger bits
    localparam S_IDLE       = 2'd0;
    localparam S_COUNT      = 2'd1;
    localparam S_WAIT_REL   = 2'd2;

    reg [1:0]  db_state [3:0];
    reg [9:0]  db_counter [3:0]; // 10-bit counter for 1024 cycles
    reg [3:0]  trigger_action;   // One-cycle pulse when a valid press is registered

    integer i;

    // ==========================================
    // Synchronous Logic
    // ==========================================
    always @(posedge Clk) begin
        if (Reset) begin
            // Reset Criteria: BCD value set to 1, overflow cleared
            current_val <= 14'd1;
            overflow_active <= 1'b0;
            trigger_action <= 4'b0000;
            // Reset debounce logic
            for (i = 0; i < 4; i = i + 1) begin
                db_state[i]   <= S_IDLE;
                db_counter[i] <= 10'd0;
            end
        end
        else begin
            trigger_action <= 4'b0000; // Default: no action

            // --------------------------------------
            // 1. Debounce Finite State Machine (per bit)
            // --------------------------------------
            for (i = 0; i < 4; i = i + 1) begin
                case (db_state[i])
                    S_IDLE: begin
                        if (Trigger[i]) begin
                            // Rising edge detected
                            trigger_action[i] <= 1'b1; // Generate action pulse immediately (Lead edge)
                            db_state[i]       <= S_COUNT;
                            db_counter[i]     <= 10'd0;
                        end
                    end

                    S_COUNT: begin
                        // Wait for 1024 cycles to filter noise
                        // We stay here regardless of Trigger input changes (glitch filtering)
                        if (db_counter[i] == 1023) begin
                            db_state[i] <= S_WAIT_REL;
                        end else begin
                            db_counter[i] <= db_counter[i] + 1'b1;
                        end
                    end

                    S_WAIT_REL: begin
                        // Wait for the button to be released (Long press handling)
                        // Trigger must be 0 to return to IDLE
                        if (!Trigger[i]) begin
                            db_state[i] <= S_IDLE;
                        end
                    end
                endcase
            end

            // --------------------------------------
            // 2. Arithmetic / Trigger Action Logic
            // --------------------------------------
            if (!overflow_active) begin
                // Check trigger actions (Priority doesn't strictly matter as only 1 is asserted at a time)
                if (trigger_action[0]) begin
                    // Trigger[0]: +1
                    if (current_val + 1 > 9999)
                        overflow_active <= 1'b1;
                    else
                        current_val <= current_val + 1;
                end
                else if (trigger_action[1]) begin
                    // Trigger[1]: +2
                    if (current_val + 2 > 9999)
                        overflow_active <= 1'b1;
                    else
                        current_val <= current_val + 2;
                end
                else if (trigger_action[2]) begin
                    // Trigger[2]: *2
                    if (current_val * 2 > 9999)
                        overflow_active <= 1'b1;
                    else
                        current_val <= current_val * 2;
                end
                else if (trigger_action[3]) begin
                    // Trigger[3]: *3
                    if (current_val * 3 > 9999)
                        overflow_active <= 1'b1;
                    else
                        current_val <= current_val * 3;
                end
            end
        end
    end

    // ==========================================
    // Output Logic (Binary to BCD Conversion)
    // ==========================================
    reg [3:0] bcd3_reg, bcd2_reg, bcd1_reg, bcd0_reg;

    always @(*) begin
        if (overflow_active) begin
            // Overflow handling: All outputs set to 1111
            bcd3_reg = 4'b1111;
            bcd2_reg = 4'b1111;
            bcd1_reg = 4'b1111;
            bcd0_reg = 4'b1111;
        end else begin
            // Convert binary 'current_val' to BCD digits
            // Using simple division/modulo for clarity given the constraints
            bcd3_reg = (current_val / 1000) % 10;
            bcd2_reg = (current_val / 100) % 10;
            bcd1_reg = (current_val / 10) % 10;
            bcd0_reg = (current_val) % 10;
        end
    end

    // Assign to outputs
    assign BCD3 = bcd3_reg;
    assign BCD2 = bcd2_reg;
    assign BCD1 = bcd1_reg;
    assign BCD0 = bcd0_reg;

endmodule
