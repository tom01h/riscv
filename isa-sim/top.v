module top
(
    input              clk,
    input              reset
);

    int reset_pc;
    int pass_pc;
    int fail_pc;

    cpu cpu (
        .clk   (clk),
        .reset (reset)
    );

    trace trace (
        .clk   (clk),
        .valid (cpu.inst_v_i),
        .pc    (cpu.pc_i),
        .inst  (cpu.inst_i)
    );

    initial begin
        if ($test$plusargs("trace") != 0) begin
            $dumpfile("dump.vcd");
            $dumpvars();
        end
        $display("[%0t] Model running...\n", $time);
        $value$plusargs("reset_pc=%x",reset_pc);
        $display("reset_pc=0x%08x", reset_pc);
        $value$plusargs("pass_pc=%x",pass_pc);
        $display("pass_pc=0x%08x", pass_pc);
        $value$plusargs("fail_pc=%x",fail_pc);
        $display("fail_pc=0x%08x", fail_pc);

        cpu.instruction.reset_pc = reset_pc;
        $display("");

        $readmemh("inst.hex", cpu.itcm.imem);
    end

    always @ (posedge clk) begin
        if (cpu.pc_i==fail_pc) begin
            $display("fail");
            $finish;
        end
    end
    
endmodule
