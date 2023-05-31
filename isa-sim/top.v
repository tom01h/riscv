module top
(
    input              clk,
    input              reset
);

    int reset_pc;
    int pass_pc;
    int fail_pc;

    cpu cpu (
        .clk     (clk),
        .reset   (reset)
    );

    trace trace (
        .clk     (clk),
        .reset   (reset),
        .valid   (cpu.inst_v_i),
        .pc      (cpu.pc_i),
        .inst    (cpu.inst_i),
        .rdv     (cpu.execution.rd_v),
        .rd_x    (cpu.execution.rd),
        .rd_data (cpu.execution.rd_data),
        .pcv     (cpu.execution.pc_v_x),
        .pc_x    (cpu.pc_x)
    );

    initial begin
        if ($test$plusargs("trace") != 0) begin
            $dumpfile("dump.vcd");
            $dumpvars();
        end
        $value$plusargs("reset_pc=%x",reset_pc);
        $display("reset_pc=0x%08x", reset_pc);
        $value$plusargs("pass_pc=%x",pass_pc);
        $display("pass_pc=0x%08x", pass_pc);
        $value$plusargs("fail_pc=%x",fail_pc);
        $display("fail_pc=0x%08x", fail_pc);

        cpu.instruction.reset_pc = reset_pc;
        $display("");

        cpu.execution.register[0] = 32'h0;
        $readmemh("inst.hex", cpu.itcm.imem);
    end

    always @ (posedge clk) begin
        if ((cpu.pc_i==fail_pc) & cpu.inst_v_i) begin
            $display("fail");
            $finish;
        end
        if ((cpu.pc_i==pass_pc) & cpu.inst_v_i) begin
            $display("pass");
            $finish;
        end
    end
    
endmodule
