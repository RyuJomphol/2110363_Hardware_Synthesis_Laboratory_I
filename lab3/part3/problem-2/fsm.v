module fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire       data_in,
    output reg  [1:0] data_out
);

    localparam A = 2'b00;
    localparam B = 2'b01;
    localparam C = 2'b10;
    localparam D = 2'b11;

    reg [1:0] state;

    always @(state) begin
        case (state)
            A: data_out <= 2'b01;
            B: data_out <= 2'b11;
            C: data_out <= 2'b00;
            D: data_out <= 2'b10;
            default: data_out <= 2'b00;
        endcase
    end

    always @(posedge clk) begin
        if (rst) state <= A;
        else begin
            case (state)
                A: state <= (data_in == 1'b1) ? B : D;
                B: state <= (data_in == 1'b1) ? C : D;
                C: state <= (data_in == 1'b1) ? B : D;
                D: state <= (data_in == 1'b1) ? B : A;
                default: state <= A;
            endcase
        end
    end

endmodule
