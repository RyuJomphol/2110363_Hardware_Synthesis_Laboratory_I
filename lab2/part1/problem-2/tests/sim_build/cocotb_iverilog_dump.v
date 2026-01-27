module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\fangj\\Downloads\\lab2-main\\lab2-main\\part1\\problem-2\\tests\\sim_build\\bcd_counter.fst");
    end
    $dumpvars(0, bcd_counter);
end
endmodule
