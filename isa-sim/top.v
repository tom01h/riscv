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

    wire inst_v_i = cpu.inst_v_i;
    wire inst_v_x = cpu.execution.inst_v_x;
    reg  inst_v_m;
    reg  inst_v_r;

    always @ (negedge clk) begin
        inst_v_m <= inst_v_x;
        inst_v_r <= inst_v_m;
    end    

    int ci = 0;
    int cx = 0;
    int cm = 0;
    int cr = 0;

    always @ (negedge clk) begin
        if(!reset)begin
            if (inst_v_i) ci <= ci + 1;
            if (inst_v_x) cx <= cx + 1;
            if (inst_v_m) cm <= cm + 1;
            if (inst_v_r) cr <= cr + 1;
        end
    end
    
    trace trace (
        .clk      (clk),
        .reset    (reset),
        .valid    (cpu.inst_v_i),
        .pc       (cpu.pc_i),
        .inst     (cpu.inst_i),
        .rdv      (cpu.ireg.rdm_v_m),
        .rd_m     (cpu.ireg.rd_m),
        .rd_data  (cpu.ireg.rd_data_m),
        .pcv      (cpu.execution.pc_v_x),
        .pc_x     (cpu.pc_x),
        .inst_v_i (inst_v_i),
        .inst_v_x (inst_v_x),
        .inst_v_m (inst_v_m),
        .inst_v_r (inst_v_r),
        .ci       (ci),
        .cx       (cx),
        .cm       (cm),
        .cr       (cr)
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

        cpu.ireg.register[0] = 32'h0;
        $readmemh("inst.hex", cpu.itcm.imem);
    end

    always @ (posedge clk) begin
        if ((cpu.pc_i==fail_pc) & cpu.inst_v_i) begin
            $display("FAIL");
            $finish;
        end
        if ((cpu.pc_i==pass_pc) & cpu.inst_v_i) begin
            $display("PASS");
            $finish;
        end
    end
    
endmodule
