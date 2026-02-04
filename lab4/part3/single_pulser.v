module single_pulser (
    input clk,
    input rst,
    input input_signal,
    output reg pulse_output
);
    reg input_delayed;
    always @(posedge clk) begin
        if (rst) begin
            input_delayed <= 0;
            pulse_output <= 0;
        end else begin
            input_delayed <= input_signal;
            pulse_output <= input_signal & (~input_delayed);
        end
    end
endmodule