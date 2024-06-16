/* verilator lint_off UNUSEDSIGNAL */
`default_nettype none

module instruction
(
    input logic clk,
    input logic reset,
    input logic stall_i,
    output logic inst_v_i,
    output logic [31:0] pc_p,
    output logic [31:0] pc_i,
    input logic pc_v_x,
    input logic [31:0] pc_x
);
    integer reset_pc = 0;

    logic reset_i, reset_d;
    always_ff @ (posedge clk)
        reset_d <= reset;
    assign reset_i = reset | reset_d;

    always_comb  begin
        if (reset_i) begin
            pc_p = reset_pc;
        end else if (pc_v_x) begin
            pc_p = pc_x;
        end else if(!stall_i)begin
            pc_p = pc_i + 'd4;
        end else begin
            pc_p = pc_i;
        end    
    end

    logic inst_v_l;
    assign inst_v_i = inst_v_l & !stall_i & !pc_v_x;

    always_ff @ (posedge clk) begin
        pc_i <= pc_p;
        if (reset) begin
            inst_v_l <= 1'b0;
        end else begin
            inst_v_l <= 1'b1;
        end
    end
endmodule
