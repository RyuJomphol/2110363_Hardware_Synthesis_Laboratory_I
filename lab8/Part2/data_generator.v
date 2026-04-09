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

localparam IDLE    = 0;
localparam GENDATA = 1;
localparam FINISH  = 2;

reg [1:0] state;

reg        s_axis_tready_reg;
reg [31:0] m_axis_tdata_reg;
reg        m_axis_tvalid_reg;
reg [3:0]  m_axis_tkeep_reg;
reg        m_axis_tlast_reg;

reg [7:0] counter;
reg [7:0] byte_count;

always @(posedge s_axis_aclk) begin

    if (s_axis_rst) begin
      state <= IDLE;
      s_axis_tready_reg <= 1'b0;
      m_axis_tvalid_reg <= 1'b0;
      m_axis_tlast_reg <= 1'b0;
      m_axis_tkeep_reg <= 4'b0;
      m_axis_tdata_reg <= 32'b0;
      counter <= 0;
    end

    else begin
        case(state)

        IDLE: begin

          s_axis_tready_reg <= 1'b1;

          if(s_axis_tvalid && s_axis_tready_reg) begin
            byte_count <= s_axis_tdata;
            counter <= 0;
            s_axis_tready_reg <= 1'b0;
            state <= GENDATA;
          end

        end

        GENDATA: begin

          if(m_axis_tready) begin

            for(integer i=0;i<4;i=i+1)
              m_axis_tdata_reg[i*8 +: 8] <= counter + i;

            m_axis_tvalid_reg <= 1'b1;

            if(counter + 4 >= byte_count) begin
              m_axis_tlast_reg <= 1'b1;

              if(byte_count - counter == 0)
                m_axis_tkeep_reg <= 4'b0000;
              else begin
                case (byte_count - counter)
                  1: m_axis_tkeep_reg <= 4'b0001;
                  2: m_axis_tkeep_reg <= 4'b0011;
                  3: m_axis_tkeep_reg <= 4'b0111;
                  default: m_axis_tkeep_reg <= 4'b1111;
                endcase
              end

              state <= FINISH;

            end else begin
              m_axis_tkeep_reg <= 4'b1111;
              counter <= counter + 4;
            end

          end
        end

        FINISH: begin

          if(m_axis_tready && m_axis_tvalid_reg) begin
            m_axis_tvalid_reg <= 0;
            m_axis_tlast_reg <= 0;
            state <= IDLE;
          end

        end

        endcase
    end
end

assign s_axis_tready = s_axis_tready_reg;
assign m_axis_tdata  = m_axis_tdata_reg;
assign m_axis_tvalid = m_axis_tvalid_reg;
assign m_axis_tkeep  = m_axis_tkeep_reg;
assign m_axis_tlast  = m_axis_tlast_reg;

endmodule
