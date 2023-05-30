/* verilator lint_off UNUSEDSIGNAL */

module itcm
(
    input clk,
    input logic [31:0] pc_p,
    output logic [31:0] inst_i
);
    logic [31:0] imem[0:1023];

    always_ff @ (posedge clk) begin
        inst_i <= imem[pc_p[11:2]];
    end
endmodule
