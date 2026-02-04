module debouncer #(
    parameter SAMPLING_RATE = 100000,
    parameter COUNTER_WIDTH = 20
) (
    input  clk,
    input  rst,
    input  data_in,
    output reg data_out
);

    reg [COUNTER_WIDTH-1:0] debounce_timer;
    reg stable_signal;

    always @(posedge clk) begin
        if (rst) begin
            debounce_timer <= 0;
            data_out <= 0;
            stable_signal <= 0;
        end else begin
            if (data_in == stable_signal) begin
                if (debounce_timer == SAMPLING_RATE - 1) begin
                    data_out <= stable_signal;
                end else begin
                    debounce_timer <= debounce_timer + 1;
                end
            end else begin
                debounce_timer <= 0;
                stable_signal <= data_in;
            end
        end 
    end

endmodule