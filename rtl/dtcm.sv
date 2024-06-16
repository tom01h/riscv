/* verilator lint_off UNUSEDSIGNAL */
`default_nettype none

module dtcm
(
    input clk,
    input logic [31:0] addr,
    input logic [3:0] wen,
    output logic [31:0] data_o,
    input logic [31:0] data_i
);
    logic [31:0] dmem[0:1023];

    always_ff @ (posedge clk) begin
        if(wen[0]) dmem[addr[11:2]][ 0+:8] <= data_i[ 0+:8];
        if(wen[1]) dmem[addr[11:2]][ 8+:8] <= data_i[ 8+:8];
        if(wen[2]) dmem[addr[11:2]][16+:8] <= data_i[16+:8];
        if(wen[3]) dmem[addr[11:2]][24+:8] <= data_i[24+:8];
        data_o <= dmem[addr[11:2]];
    end
endmodule
