module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\fangj\\Documents\\hardware_lab\\lab1\\part2\\part2-3\\tests\\sim_build\\dff_sync_reset.fst");
    end
    $dumpvars(0, dff_sync_reset);
end
endmodule
