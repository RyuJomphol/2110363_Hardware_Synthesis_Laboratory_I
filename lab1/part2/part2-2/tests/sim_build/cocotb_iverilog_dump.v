module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\fangj\\Documents\\hardware_lab\\lab1\\part2\\part2-2\\tests\\sim_build\\full_adder_4_bit.fst");
    end
    $dumpvars(0, full_adder_4_bit);
end
endmodule
