module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\fangj\\Documents\\hardware_lab\\lab1\\part2\\part2-1\\tests\\sim_build\\xnor_xor.fst");
    end
    $dumpvars(0, xnor_xor);
end
endmodule
