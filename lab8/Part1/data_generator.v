`timescale 1ns / 1ps

module data_generator (
    input  wire        s_axis_aclk,
    input  wire        s_axis_rst,
    // AXI Stream Slave Interface
    input  wire [ 7:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    // AXI Stream Master Interface
    output wire [31:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire [ 3:0] m_axis_tkeep,
    output wire        m_axis_tlast,
    // For Waveform debugging not used
    input  wire [ 9:0] testcase_id
);

    //TODO
    reg [31:0] data_reg;
    reg        valid_reg;
    reg [7:0]  target_bytes;
    reg [7:0]  current_bytes;
    reg        is_running;

    // --- Assignments ---
    assign s_axis_tready = !is_running && !s_axis_rst;
    assign m_axis_tdata  = data_reg;
    assign m_axis_tvalid = valid_reg;

    wire [7:0] bytes_left = (target_bytes > current_bytes) ? (target_bytes - current_bytes) : 8'd0;
    
    // tkeep สำหรับกรณี 0 byte ต้องเป็น 4'h0
    assign m_axis_tkeep  = (is_running && target_bytes == 0) ? 4'h0 :
                           (bytes_left >= 4) ? 4'hF : 
                           (bytes_left == 3) ? 4'h7 :
                           (bytes_left == 2) ? 4'h3 :
                           (bytes_left == 1) ? 4'h1 : 4'h0;

    // tlast สำหรับกรณี 0 byte ต้อง High ทันที
    assign m_axis_tlast  = is_running && (target_bytes == 0 || current_bytes + 4 >= target_bytes);

    always @(posedge s_axis_aclk) begin
        if (s_axis_rst) begin
            valid_reg     <= 1'b0;
            data_reg      <= 32'h0;
            current_bytes <= 8'd0;
            target_bytes  <= 8'd0;
            is_running    <= 1'b0;
        end else begin
            if (!is_running) begin
                if (s_axis_tvalid && s_axis_tready) begin
                    target_bytes  <= s_axis_tdata;
                    current_bytes <= 8'd0;
                    data_reg      <= 32'h03020100;
                    valid_reg     <= 1'b1; // ส่ง valid ออกไปแจ้ง sink เสมอ
                    is_running    <= 1'b1;
                end
            end else begin
                if (m_axis_tvalid && m_axis_tready) begin
                    if (m_axis_tlast) begin
                        valid_reg  <= 1'b0;
                        is_running <= 1'b0;
                    end else begin
                        data_reg[7:0]   <= data_reg[7:0]   + 4;
                        data_reg[15:8]  <= data_reg[15:8]  + 4;
                        data_reg[23:16] <= data_reg[23:16] + 4;
                        data_reg[31:24] <= data_reg[31:24] + 4;
                        current_bytes   <= current_bytes + 4;
                    end
                end
            end
        end
    end

endmodule
