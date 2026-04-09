module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\fangj\\Documents\\hardware_lab\\lab8\\Part1\\sim_build\\data_generator.fst");
    end
    $dumpvars(0, data_generator);
end
endmodule
