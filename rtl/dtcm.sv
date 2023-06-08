/* verilator lint_off UNUSEDSIGNAL */

module dtcm
(
    input clk,
    input logic [31:0] addr,
    output logic [31:0] data_o
);
    logic [31:0] dmem[0:1023];

    always_ff @ (posedge clk) begin
        data_o <= dmem[addr[11:2]];
    end
endmodule
