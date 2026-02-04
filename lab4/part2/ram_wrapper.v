module ram_wrapper (
    input  wire        clk,
    input  wire        ena,
    input  wire        wea,
    input  wire [7:0] addr,    // TODO: Specify correct width
    input  wire [15:0] din,
    output wire [15:0] dout
);

    // TODO: Instantiate RAM module created with IP
    blk_mem_ram ram_inst (
    .clka(clk),
    .wea(wea),
    .ena(ena),
    .addra(addr),
    .dina(din),
    .douta(dout)
);



endmodule
