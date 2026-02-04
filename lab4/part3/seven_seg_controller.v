`timescale 1ns / 1ps

module seven_seg_controller(
    input [3:0] Digit_1_Value,
    input [3:0] Digit_2_Value,
    input [3:0] Digit_3_Value,
    input [3:0] Digit_4_Value,
    input Clk,
    input Reset,
    output reg [3:0] AN,
    output reg [6:0] Display
    );
    reg [3:0] current_digit;     // 4 bits to represent values 0-9 for BCD
    wire [1:0] active_digit_position;   // 2 bits to represent 4 positions on the board
    reg [19:0] multiplexing_refresh_counter;  // 20-bit counter for refresh rate

    always @(posedge Clk) begin
        if (Reset)
            multiplexing_refresh_counter <= 0;
        else
            multiplexing_refresh_counter <= multiplexing_refresh_counter + 1;
    end

    assign active_digit_position = multiplexing_refresh_counter[19:18];

    always @(*) begin
        if (Reset) begin
            AN = 4'b0000;
            current_digit = 4'b0000;
        end else begin
            case (active_digit_position)
                2'b00: begin
                    AN = 4'b0111; // Activate Digit 1 (Leftmost)
                    current_digit = Digit_1_Value;
                end
                2'b01: begin
                    AN = 4'b1011; // Activate Digit 2
                    current_digit = Digit_2_Value;
                end
                2'b10: begin
                    AN = 4'b1101; // Activate Digit 3
                    current_digit = Digit_3_Value;
                end
                2'b11: begin
                    AN = 4'b1110; // Activate Digit 4 (Rightmost)
                    current_digit = Digit_4_Value;
                end
                default: begin
                    AN = 4'b1111; // All digits off
                    current_digit = 4'b0000;
                end
            endcase
        end
    end

    always @(*) begin
        case (current_digit)
            4'h0: Display = 7'b1000000;
            4'h1: Display = 7'b1111001;
            4'h2: Display = 7'b0100100;
            4'h3: Display = 7'b0110000;
            4'h4: Display = 7'b0011001;
            4'h5: Display = 7'b0010010;
            4'h6: Display = 7'b0000010;
            4'h7: Display = 7'b1111000;
            4'h8: Display = 7'b0000000;
            4'h9: Display = 7'b0010000;
            4'hA: Display = 7'b0001000;
            4'hB: Display = 7'b0000011;
            4'hC: Display = 7'b1000110;
            4'hD: Display = 7'b0100001;
            4'hE: Display = 7'b0000110;
            4'hF: Display = 7'b0001110;
            default: Display = 7'b1111111;
        endcase
    end


endmodule
