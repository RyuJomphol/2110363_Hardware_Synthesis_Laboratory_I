module UARTTx (
    input wire Clk,
    input wire Reset,
    output wire Tx,
    input wire [7:0] DataIn,
    input wire DataValid,
    output reg DataReady,
    input wire fifo_empty
);
    // Add your code here
    
    //Timing
    parameter CLKS_PER_BIT = 868;
    
    //FSM
    localparam IDLE      = 3'b000;
    localparam WAIT_DATA = 3'b001;
    localparam START_BIT = 3'b010;
    localparam DATA_BITS = 3'b011;
    localparam STOP_BIT  = 3'b100;
    
    //Register
    reg [2:0] current_state;
    reg [9:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] tx_data;
    reg       tx_out;
    
    assign Tx = tx_out;
    
    always @(posedge Clk) begin
        if (Reset) begin
            current_state <= IDLE;
            clk_count     <= 0;
            bit_index     <= 0;
            tx_data       <= 0;
            tx_out        <= 1'b1; // UART Idle is High
            DataReady     <= 1'b0;
        end else begin
            case (current_state)

                // Maintain Tx High. Check if FIFO has data.
                IDLE: begin
                    tx_out <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;
                    
                    if (!fifo_empty) begin
                        // FIFO is not empty, tell controller we are ready for data
                        DataReady <= 1'b1;
                        current_state <= WAIT_DATA;
                    end else begin
                        DataReady <= 1'b0;
                    end
                end

                // Wait for the handshake (DataValid) to lat
                WAIT_DATA: begin
                    DataReady <= 1'b0;
                    
                    if (DataValid) begin
                        tx_data <= DataIn; // Latch data
                        current_state <= START_BIT;
                    end
                end

                // Drive Tx Low for 868 cycles
                START_BIT: begin
                    tx_out <= 1'b0; // Start bit is Low
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        current_state <= DATA_BITS;
                    end
                end

                // Shift out 8 bits, LSB first
                DATA_BITS: begin
                    tx_out <= tx_data[bit_index]; // Send current bit (LSB first)
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            current_state <= STOP_BIT;
                        end
                    end
                end
                
                // Drive Tx High for 868 cycles
                STOP_BIT: begin
                    tx_out <= 1'b1; // Stop bit is High
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        current_state <= IDLE;
                    end
                end

                default: current_state <= IDLE;
            endcase
        end
    end
    
    // End your code here
endmodule
