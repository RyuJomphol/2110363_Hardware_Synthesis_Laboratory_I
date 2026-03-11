module UARTRx (
    input wire Clk,
    input wire Reset,
    input wire Rx,
    output reg [7:0] DataOut,
    output reg DataValid,
    input wire DataReady
);
    // Add your code here
    
    // Period calculations
    localparam BIT_PERIOD = 868;
    localparam HALF_PERIOD = 434;
    
    // State
    localparam IDLE       = 3'b000;
    localparam START_BIT  = 3'b001;
    localparam DATA_BITS   = 3'b010;
    localparam STOP_BIT   = 3'b011;
    localparam VALID_DATA = 3'b100;
    
    reg [2:0] state, next_state;
    
    reg [9:0] clock_count;
    reg [2:0] bit_index;
    reg [7:0] shift_reg;
    
    //Seq Logic (State & Data)
    always @(posedge Clk) begin
        if (Reset) begin
            state       <= IDLE;
            clock_count <= 0;
            bit_index   <= 0;
            shift_reg   <= 0;
            DataOut     <= 0;
            DataValid   <= 0;
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    clock_count <= 0;
                    bit_index   <= 0;
                end
                
                START_BIT: begin
                    if (clock_count < HALF_PERIOD)
                        clock_count <= clock_count + 1;
                    else
                        clock_count <= 0;
                end
                
                DATA_BITS: begin
                    if (clock_count < BIT_PERIOD - 1) begin
                        clock_count <= clock_count + 1;
                    end else begin
                        clock_count <= 0;
                        shift_reg[bit_index] <= Rx;
                        bit_index <= bit_index + 1;
                    end
                end
                
                STOP_BIT: begin
                    if (clock_count < BIT_PERIOD - 1)
                        clock_count <= clock_count + 1;
                    else begin
                        DataOut <= shift_reg;
                        DataValid <= 1;
                    end
                end
                
                VALID_DATA: begin
                    if (DataReady) begin
                        DataValid <= 0;
                    end
                end 
            endcase 
        end
    end
    
    //Com Logic (Next State)
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (Rx == 0)
                    next_state = START_BIT;
            end
            
            START_BIT: begin
                if (clock_count >= HALF_PERIOD) begin
                    if (Rx == 0)
                        next_state = DATA_BITS;
                    else
                        next_state = IDLE;
                end
            end
            
            DATA_BITS: begin
                if (clock_count >= BIT_PERIOD - 1) begin
                    if (bit_index == 7)
                        next_state = STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                if (clock_count >= BIT_PERIOD - 1) begin
                    next_state = VALID_DATA;
                end
            end
            
            VALID_DATA: begin
            if (DataReady)
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase 
    end
    
    // End of your code
endmodule
