/* verilator lint_off UNUSEDSIGNAL */

module cpu
(
    input logic clk,
    input logic reset
);
    logic reset_p, reset_d;
    always_ff @ (posedge clk)
        reset_d <= reset;
    assign reset_p = reset | reset_d;

    logic inst_v_i;
    logic [31:0] pc_p;
    logic [31:0] pc_i;
    logic [31:0] pc_x;

    logic pc_v_x;

    instruction instruction
    (
        .clk      (clk),
        .reset    (reset_p),
        .inst_v_i (inst_v_i),
        .pc_p     (pc_p),
        .pc_i     (pc_i),
        .pc_v_x   (pc_v_x),
        .pc_x     (pc_x)
    );

    logic [31:0] inst_i;
    
    itcm itcm
    (
        .clk      (clk),
        .pc_p     (pc_p),
        .inst_i   (inst_i)
        
    );

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic rd_v;
    logic signed [31:0] rd_data;
    logic signed [31:0] rs1_data;
    logic signed [31:0] rs2_data;

    execution execution
    (
        .clk      (clk),
        .reset    (reset_p),
        .pc_i     (pc_i),
        .inst_v_i (inst_v_i),
        .inst_i   (inst_i),
        .pc_v_x   (pc_v_x),
        .pc_x     (pc_x),
        .rs1      (rs1),
        .rs2      (rs2),
        .rd       (rd),
        .rd_v     (rd_v),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    ireg ireg
    (
        .clk       (clk),
        .rs1       (rs1),
        .rs2       (rs2),
        .rd        (rd),
        .rdx_v     (rd_v),
        .rdm_v     (rd_v),
        .rd_data_x (rd_data),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );
    
endmodule
