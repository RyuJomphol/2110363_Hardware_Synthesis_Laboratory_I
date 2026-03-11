// This module is already implemented
module UARTLedSystem (
    input  wire        Clk,
    input  wire        Reset,
    input  wire        SentUartData,
    input  wire [ 7:0] Sw,
    output wire        UARTTx,
    input  wire        UARTRx,
    output wire [15:0] Led
);

    wire        clean_btn;
    wire [7:0] tx_fifo_to_uart_data;
    wire        tx_fifo_empty;
    wire        tx_fifo_valid;
    wire        tx_uart_ready;

    InputSanitizer InputSanitizerInst (
        .Clk(Clk),
        .Reset(Reset),
        .DataIn(SentUartData),
        .DataOut(clean_btn)
    );

    DataBuffer TxDataBufferInst (
        .clk  (Clk),
        .srst (Reset),
        .full (),
        .din  (Sw),
        .wr_en(clean_btn),
        .empty(tx_fifo_empty),
        .dout (tx_fifo_to_uart_data),
        .rd_en(tx_uart_ready),
        .valid(tx_fifo_valid)
    );

    UARTTx UARTTxInst (
        .Clk       (Clk),
        .Reset     (Reset),
        .Tx        (UARTTx),
        .DataIn    (tx_fifo_to_uart_data),
        .DataValid (tx_fifo_valid),
        .DataReady (tx_uart_ready),
        .fifo_empty(tx_fifo_empty)
    );

    wire [7:0] rx_uart_to_fifo_data;
    wire        rx_uart_valid;
    wire        rx_fifo_full;
    wire [7:0] rx_fifo_to_ctrl_data;
    wire        rx_fifo_empty;
    wire        rx_fifo_valid;
    wire        rx_ctrl_ready;

    UARTRx UARTRxInst (
        .Clk        (Clk),
        .Reset      (Reset),
        .Rx         (UARTRx),
        .DataOut    (rx_uart_to_fifo_data),
        .DataValid  (rx_uart_valid),
        .DataReady  (!rx_fifo_full)
    );

    DataBuffer RxDataBufferInst (
        .clk  (Clk),
        .srst (Reset),
        .full (rx_fifo_full),
        .din  (rx_uart_to_fifo_data),
        .wr_en(rx_uart_valid),
        .empty(rx_fifo_empty),
        .dout (rx_fifo_to_ctrl_data),
        .rd_en(rx_ctrl_ready),
        .valid(rx_fifo_valid)
    );

    LedController LedControllerInst (
        .Clk       (Clk),
        .Reset     (Reset),
        .DataIn    (rx_fifo_to_ctrl_data),
        .DataValid (rx_fifo_valid),
        .DataReady (rx_ctrl_ready),
        .Led       (Led)
    );

endmodule
