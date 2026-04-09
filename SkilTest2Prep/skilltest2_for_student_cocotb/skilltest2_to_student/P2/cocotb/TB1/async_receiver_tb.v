module async_receiver_tb (
    input clk,
    input RxD,  // UART Tx line from testbench -> DUT Rx
    output RxD_data_ready,
    output [7:0] RxD_data,
    output RxD_idle,
    output RxD_endofpacket
);
  // UART Parameters
  localparam BitDelayNs = 1000000000 / 115200;  // Bit delay in ns (for 115200 baud rate)
  // Parameters
  localparam ClkFrequency = 25000000;  // 25MHz
  localparam Baud = 115200;
  localparam Oversampling = 16;  // Must match the DUT setting

  async_receiver #(
      .ClkFrequency(ClkFrequency),
      .Baud(Baud),
      .Oversampling(Oversampling)
  ) DUT (
      .clk(clk),
      .RxD(RxD),  // Connect TB Tx to DUT Rx
      .RxD_data_ready(RxD_data_ready),
      .RxD_data(RxD_data),
      .RxD_idle(RxD_idle),
      .RxD_endofpacket(RxD_endofpacket)
  );

`ifdef COCOTB_SIM
  initial begin
    $dumpfile("waveform.vcd");  // Name of the dump file
    $dumpvars(0, async_receiver_tb);  // Dump all variables for the top module
  end
`endif
endmodule
