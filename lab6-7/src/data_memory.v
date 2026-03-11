// For student: Do not modify this file! You can read it to understand how the data memory works, but you should not change it.
// For control signal in this module, please use funct3 so that the grader will work
// 128x8-bit memory, byte-addressable, 1 word = 4 bytes
// with single-cycle bulk reset

module data_memory (
    input  wire        clk,         // Clock
    input  wire        rst,         // Active high reset
    input  wire        mem_write,   // [Control Signal] Memory write signal
    input  wire        mem_read,    // [Control Signal] Memory read signal
    input  wire [31:0] address,     // Address that is read or written
    input  wire [31:0] write_data,  // Data to be written
    input  wire [ 2:0] data_mask,   // [Control Signal] Data mask, which is usually funct3, indicating how many bytes to read/write (for separate byte/half-word/word and signed/unsigned cases)
    output reg  [31:0] read_data,   // Data that is read
    input  wire [ 7:0] sw,          // (Lab 7) Memory mapped I/O: switch input
    output wire [ 7:0] led          // (Lab 7) Memory mapped I/O: LED output
);

    reg [7:0] memory[127:0];

    // Mamory mapped I/O: connect the byte at address 84 (dec) to the LED output, 
    // and the byte at address 80 (dec) to the switch input
    assign led = memory[84];

    always @(negedge clk) begin
        if (rst) begin
            memory[0]   <= 8'b0;
            memory[1]   <= 8'b0;
            memory[2]   <= 8'b0;
            memory[3]   <= 8'b0;
            memory[4]   <= 8'b0;
            memory[5]   <= 8'b0;
            memory[6]   <= 8'b0;
            memory[7]   <= 8'b0;
            memory[8]   <= 8'b0;
            memory[9]   <= 8'b0;
            memory[10]  <= 8'b0;
            memory[11]  <= 8'b0;
            memory[12]  <= 8'b0;
            memory[13]  <= 8'b0;
            memory[14]  <= 8'b0;
            memory[15]  <= 8'b0;
            memory[16]  <= 8'b0;
            memory[17]  <= 8'b0;
            memory[18]  <= 8'b0;
            memory[19]  <= 8'b0;
            memory[20]  <= 8'b0;
            memory[21]  <= 8'b0;
            memory[22]  <= 8'b0;
            memory[23]  <= 8'b0;
            memory[24]  <= 8'b0;
            memory[25]  <= 8'b0;
            memory[26]  <= 8'b0;
            memory[27]  <= 8'b0;
            memory[28]  <= 8'b0;
            memory[29]  <= 8'b0;
            memory[30]  <= 8'b0;
            memory[31]  <= 8'b0;
            memory[32]  <= 8'b0;
            memory[33]  <= 8'b0;
            memory[34]  <= 8'b0;
            memory[35]  <= 8'b0;
            memory[36]  <= 8'b0;
            memory[37]  <= 8'b0;
            memory[38]  <= 8'b0;
            memory[39]  <= 8'b0;
            memory[40]  <= 8'b0;
            memory[41]  <= 8'b0;
            memory[42]  <= 8'b0;
            memory[43]  <= 8'b0;
            memory[44]  <= 8'b0;
            memory[45]  <= 8'b0;
            memory[46]  <= 8'b0;
            memory[47]  <= 8'b0;
            memory[48]  <= 8'b0;
            memory[49]  <= 8'b0;
            memory[50]  <= 8'b0;
            memory[51]  <= 8'b0;
            memory[52]  <= 8'b0;
            memory[53]  <= 8'b0;
            memory[54]  <= 8'b0;
            memory[55]  <= 8'b0;
            memory[56]  <= 8'b0;
            memory[57]  <= 8'b0;
            memory[58]  <= 8'b0;
            memory[59]  <= 8'b0;
            memory[60]  <= 8'b0;
            memory[61]  <= 8'b0;
            memory[62]  <= 8'b0;
            memory[63]  <= 8'b0;
            memory[64]  <= 8'b0;
            memory[65]  <= 8'b0;
            memory[66]  <= 8'b0;
            memory[67]  <= 8'b0;
            memory[68]  <= 8'b0;
            memory[69]  <= 8'b0;
            memory[70]  <= 8'b0;
            memory[71]  <= 8'b0;
            memory[72]  <= 8'b0;
            memory[73]  <= 8'b0;
            memory[74]  <= 8'b0;
            memory[75]  <= 8'b0;
            memory[76]  <= 8'b0;
            memory[77]  <= 8'b0;
            memory[78]  <= 8'b0;
            memory[79]  <= 8'b0;
            memory[80]  <= sw; // Mem mapped I/O: Connect the switch input to memory address 80
            memory[81]  <= 8'b0;
            memory[82]  <= 8'b0;
            memory[83]  <= 8'b0;
            memory[84]  <= 8'b0;
            memory[85]  <= 8'b0;
            memory[86]  <= 8'b0;
            memory[87]  <= 8'b0;
            memory[88]  <= 8'b0;
            memory[89]  <= 8'b0;
            memory[90]  <= 8'b0;
            memory[91]  <= 8'b0;
            memory[92]  <= 8'b0;
            memory[93]  <= 8'b0;
            memory[94]  <= 8'b0;
            memory[95]  <= 8'b0;
            memory[96]  <= 8'b0;
            memory[97]  <= 8'b0;
            memory[98]  <= 8'b0;
            memory[99]  <= 8'b0;
            memory[100] <= 8'b0;
            memory[101] <= 8'b0;
            memory[102] <= 8'b0;
            memory[103] <= 8'b0;
            memory[104] <= 8'b0;
            memory[105] <= 8'b0;
            memory[106] <= 8'b0;
            memory[107] <= 8'b0;
            memory[108] <= 8'b0;
            memory[109] <= 8'b0;
            memory[110] <= 8'b0;
            memory[111] <= 8'b0;
            memory[112] <= 8'b0;
            memory[113] <= 8'b0;
            memory[114] <= 8'b0;
            memory[115] <= 8'b0;
            memory[116] <= 8'b0;
            memory[117] <= 8'b0;
            memory[118] <= 8'b0;
            memory[119] <= 8'b0;
            memory[120] <= 8'b0;
            memory[121] <= 8'b0;
            memory[122] <= 8'b0;
            memory[123] <= 8'b0;
            memory[124] <= 8'b0;
            memory[125] <= 8'b0;
            memory[126] <= 8'b0;
            memory[127] <= 8'b0;
        end else begin
            if (mem_write) begin
                case (data_mask)
                    // SB: store byte
                    3'b000: begin
                        memory[address] <= write_data[7:0];
                    end
                    // SH: store half-word
                    3'b001: begin
                        memory[address]   <= write_data[7:0];
                        memory[address+1] <= write_data[15:8];
                    end
                    // SW: store word
                    3'b010: begin
                        memory[address]   <= write_data[7:0];
                        memory[address+1] <= write_data[15:8];
                        memory[address+2] <= write_data[23:16];
                        memory[address+3] <= write_data[31:24];
                    end
                    // Default case: treat it as SW (store word)
                    default: begin
                        memory[address]   <= write_data[7:0];
                        memory[address+1] <= write_data[15:8];
                        memory[address+2] <= write_data[23:16];
                        memory[address+3] <= write_data[31:24];
                    end
                endcase

            end

        end
    end

    always @(*) begin
        if (mem_read) begin
            // Memory mapped I/O: If the address is 80 (dec), read from the switch
            case (data_mask)
                // LB: load byte (sign-extended)
                3'b000: begin
                    read_data = {{24{(address == 31'd80 ? sw[7] : memory[address][7])}}, (address == 31'd80 ? sw : memory[address])};
                end
                // LH: load half-word (sign-extended)
                3'b001: begin
                    read_data = {{16{(address + 31'd1 == 31'd80 ? sw[7] : memory[address + 1][7])}}, (address + 31'd1 == 31'd80 ? sw : memory[address + 1]), (address == 31'd80 ? sw : memory[address])};
                end
                // LW: load word
                3'b010: begin
                    read_data = {(address + 31'd3 == 31'd80 ? sw : memory[address + 3]), (address + 31'd2 == 31'd80 ? sw : memory[address + 2]), (address + 31'd1 == 31'd80 ? sw : memory[address + 1]), (address == 31'd80 ? sw : memory[address])};
                end
                // LBU: load byte (zero-extended)
                3'b100: begin
                    read_data = {24'b0, (address == 31'd80 ? sw : memory[address])};
                end
                // LHU: load half-word (zero-extended)
                3'b101: begin
                    read_data = {16'b0, (address + 31'd1 == 31'd80 ? sw : memory[address + 1]), (address == 31'd80 ? sw : memory[address])};
                end
                // Default case: treat it as LW (load word)
                default: begin
                    read_data = {(address + 31'd3 == 31'd80 ? sw : memory[address + 3]), (address + 31'd2 == 31'd80 ? sw : memory[address + 2]), (address + 31'd1 == 31'd80 ? sw : memory[address + 1]), (address == 31'd80 ? sw : memory[address])};
                end
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

endmodule

