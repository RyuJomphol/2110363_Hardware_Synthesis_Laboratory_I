module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\fangj\\Downloads\\lab2-main\\lab2-main\\part1\\problem-1\\tests\\sim_build\\moore_fsm.fst");
    end
    $dumpvars(0, moore_fsm);
end
endmodule
