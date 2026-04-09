`timescale 1ns / 1ps

module uart_top (
    input  wire        clk,
    input  wire        btnc_0,// Reset Button (active low)
    output reg  [3:0]  awaddr,    // Write Address
    output reg         awvalid,
    input  wire        awready,
    output reg  [31:0] wdata,     // Write Data
    output reg         wvalid,
    input  wire        wready,
    input  wire        bvalid,
    output reg         bready,
    output reg  [3:0]  araddr,    // Read Address
    output reg         arvalid,
    input  wire        arready,
    input  wire [31:0] rdata,     // Read Data
    input  wire        rvalid,
    output reg         rready
);

    wire debounced_reset;
    debouncer #(.SAMPLING_RATE(100000), .COUNTER_WIDTH(17)) deb_inst (
        .clk(clk),
        .data_in(btnc_0),
        .data_out(debounced_reset)
    );

    localparam IDLE   = 0, CHECK_RX = 1, READ_DATA = 2,
               WAIT_R = 3, SEND_DATA = 4, WAIT_W = 5;
    reg [2:0] state = IDLE;
    reg [7:0] temp_data;

    localparam RX_FIFO = 4'h0;
    localparam TX_FIFO = 4'h4;
    localparam STATUS  = 4'h8;

    always @(posedge clk) begin
        if (debounced_reset) begin
            state <= IDLE;
            awvalid <= 0; wvalid <= 0; arvalid <= 0; rready <= 0; bready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    araddr  <= STATUS;
                    arvalid <= 1;
                    rready  <= 1;  // Set rready early
                    state   <= CHECK_RX;
                end

                CHECK_RX: begin
                    if (arready) arvalid <= 0;
                    if (rvalid && rready) begin
                        rready <= 0;
                        if (rdata[0] == 1'b1) state <= READ_DATA;
                        else state <= IDLE;
                    end
                end

                READ_DATA: begin
                    araddr  <= RX_FIFO;
                    arvalid <= 1;
                    rready  <= 1;  // Set rready for read
                    state   <= WAIT_R;
                end

                WAIT_R: begin
                    if (arready) arvalid <= 0;
                    if (rvalid && rready) begin
                        temp_data <= rdata[7:0];  // Echo original, no +1
                        rready    <= 0;
                        state     <= SEND_DATA;
                    end
                end

                SEND_DATA: begin
                    awaddr  <= TX_FIFO;
                    awvalid <= 1;
                    wdata   <= temp_data;
                    wvalid  <= 1;
                    bready  <= 1;
                    state   <= WAIT_W;
                end

                WAIT_W: begin
                    if (awready) awvalid <= 1'b0;
                    if (wready)  wvalid  <= 1'b0;
                    if (bvalid && bready) begin
                        bready <= 1'b0;
                        state  <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
