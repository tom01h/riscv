/* verilator lint_off UNUSEDSIGNAL */

module cpu
(
    input clk,
    input reset
);
    logic reset_p, reset_d;
    always_ff @ (posedge clk)
        reset_d <= reset;
    assign reset_p = reset | reset_d;

    logic inst_v_i;
    logic [31:0] pc_p;
    logic [31:0] pc_i;

    instruction instruction
    (
        .clk      (clk),
        .reset    (reset_p),
        .inst_v_i (inst_v_i),
        .pc_p     (pc_p),
        .pc_i     (pc_i)
        
    );

    logic [31:0] inst_i;
    
    itcm itcm
    (
        .clk      (clk),
        .pc_p     (pc_p),
        .inst_i   (inst_i)
        
    );

    execution execution
    (
        .clk      (clk),
        .reset    (reset_p),
        .inst_v_i (inst_v_i),
        .inst_i   (inst_i)
    );
endmodule
