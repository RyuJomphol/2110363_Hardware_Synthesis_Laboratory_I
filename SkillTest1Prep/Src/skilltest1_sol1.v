`timescale 1ns / 1ps

module skilltest1_sol1 (
    input  wire       Clk,
    input  wire       Reset,
    input  wire [3:0] Trigger,
    output wire [3:0] BCD0,
    output wire [3:0] BCD1,
    output wire [3:0] BCD2,
    output wire [3:0] BCD3
);

    // Initialize variables
    reg [15:0]  currentBCD;
    reg [3:0]   currentBCD0;
    reg [3:0]   currentBCD1;
    reg [3:0]   currentBCD2;
    reg [3:0]   currentBCD3;

    reg [15:0]  counter;
    reg [3:0]   prevTrigger;
    reg         debounceEnable;
    reg         overflow;

    // Output assignment
    assign BCD0 = currentBCD0;
    assign BCD1 = currentBCD1;
    assign BCD2 = currentBCD2;
    assign BCD3 = currentBCD3;

    // Single Logic Block to prevent multi-driver issues
    always @(posedge Clk) begin
        if (Reset) begin
            // *** Reset Condition: Highest Priority ***
            currentBCD      <= 16'd1;

            // Reset Outputs to 0001
            currentBCD0     <= 4'd1;
            currentBCD1     <= 4'd0;
            currentBCD2     <= 4'd0;
            currentBCD3     <= 4'd0;

            // Reset Internal States
            counter         <= 0;
            prevTrigger     <= 0;
            debounceEnable  <= 1;
            overflow        <= 0;
        end
        else begin
            // *** Normal Operation ***

            // 1. Update Outputs based on currentBCD (Pipeline behavior)
            if (overflow) begin
                currentBCD0 <= 4'b1111;
                currentBCD1 <= 4'b1111;
                currentBCD2 <= 4'b1111;
                currentBCD3 <= 4'b1111;
            end else begin
                currentBCD0 <= currentBCD % 10;
                currentBCD1 <= (currentBCD / 10) % 10;
                currentBCD2 <= (currentBCD / 100) % 10;
                currentBCD3 <= (currentBCD / 1000) % 10;
            end

            // 2. Debounce and Trigger Logic
            if (debounceEnable) begin
                if (Trigger != 0) begin
                    // Rising Edge Detected
                    prevTrigger     <= Trigger;
                    debounceEnable  <= 0;
                    counter         <= 1;

                    // --- Action Logic (Moved here to happen on trigger detection) ---
                    if (!overflow) begin
                        case (Trigger)
                            4'b0001: begin // +1
                                if (currentBCD + 1 > 9999) overflow <= 1;
                                else currentBCD <= currentBCD + 1;
                            end
                            4'b0010: begin // +2
                                if (currentBCD + 2 > 9999) overflow <= 1;
                                else currentBCD <= currentBCD + 2;
                            end
                            4'b0100: begin // *2
                                if (currentBCD * 2 > 9999) overflow <= 1;
                                else currentBCD <= currentBCD * 2;
                            end
                            4'b1000: begin // *3
                                if (currentBCD * 3 > 9999) overflow <= 1;
                                else currentBCD <= currentBCD * 3;
                            end
                        endcase
                    end
                    // -----------------------------------------------------------
                end
            end
            else begin
                // Debounce Wait State
                if (counter < 1023) begin
                    counter <= counter + 1;
                end
                else begin
                    // Wait for Trigger to be released or changed
                    // (Logic: ถ้า Trigger เปลี่ยนสถานะจากตอนที่กด ถึงจะยอมให้รับค่าใหม่)
                    if (Trigger != prevTrigger) begin
                        debounceEnable <= 1;
                        counter        <= 0;
                    end
                end
            end
        end
    end

endmodule
