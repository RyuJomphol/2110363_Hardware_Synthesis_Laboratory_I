module moore_fsm (
    input        clk,
    input        rst,
    input        in,
    output [2:0] out
);


    localparam S0 = 3'b000,
               S1 = 3'b011,
               S2 = 3'b100,
               S3 = 3'b101,
               S4 = 3'b010,
               S5 = 3'b001;

    reg [2:0] state, next_state;


    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end


    always @(*) begin
        case (state)
            S0: next_state = S1;
            S1: next_state = (in ? S2 : S4);
            S2: next_state = (in ? S3 : S1);
            S3: next_state = (in ? S5 : S2);
            S4: next_state = (in ? S1 : S5);
            S5: next_state = S5;
            default: next_state = S0;
        endcase
    end
    assign out = state;

endmodule