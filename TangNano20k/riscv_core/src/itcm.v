`default_nettype none

module itcm (
    clk,
    pc_p,
    inst_i
);
    input clk;
    input wire [31:0] pc_p;
    output wire [31:0] inst_i;

    imem imem(
        .dout(inst_i), //output [31:0] dout
        .clk(clk),
        .oce(1'b1),
        .ce(1'b1),
        .reset(1'b0),
        .wre(1'b0),
        .ad(pc_p[11:2]), //input [9:0] ad
        .din(32'h0)
    );
endmodule
