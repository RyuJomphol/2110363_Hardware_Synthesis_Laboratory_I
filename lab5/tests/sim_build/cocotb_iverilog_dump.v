module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\fangj\\Documents\\hardware_lab\\lab5\\tests\\sim_build\\UARTTx.fst");
    end
    $dumpvars(0, UARTTx);
end
endmodule
