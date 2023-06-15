module dtcm (
    clk,
    addr,
    wen,
    data_o,
    data_i
);
    input clk;
    input wire [31:0] addr;
    input wire [3:0] wen;
    output wire [31:0] data_o;
    input wire [31:0] data_i;
    
    dmem dmem(
        .dout(data_o), //output [31:0] dout
        .clk(clk),
        .oce(1'b1),
        .ce(1'b1),
        .reset(1'b0),
        .wre(|wen),
        .wen(wen),
        .ad(addr[11:2]), //input [9:0] ad
        .din(data_i)
    );
endmodule
