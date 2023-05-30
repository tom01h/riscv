/* verilator lint_off UNUSEDSIGNAL */

module instruction
(
    input clk,
    input reset,
    output logic inst_v_i,
    output logic [31:0] pc_p,
    output logic [31:0] pc_i
);
    integer reset_pc = 0;

    logic reset_i, reset_d;
    always_ff @ (posedge clk)
        reset_d <= reset;
    assign reset_i = reset | reset_d;

    always_comb  begin
        if (reset_i) begin
            pc_p = reset_pc;
        end
        else begin
            pc_p = pc_i + 'd4;
        end
    end

    always_ff @ (posedge clk) begin
        pc_i <= pc_p;
        if (reset) begin
            inst_v_i <= 1'b0;
        end
        else begin
            inst_v_i <= 1'b1;
        end
    end
endmodule
