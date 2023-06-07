/* verilator lint_off UNUSEDSIGNAL */

module ireg
(
    input clk,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input rd_v,
    input logic signed [31:0] rd_data,
    output logic signed [31:0] rs1_data,
    output logic signed [31:0] rs2_data
);

    logic signed [31:0] register [0:31];
    logic signed [31:0] rs1_rdata;
    logic rs1_bypass;
    logic signed [31:0] rs2_rdata;
    logic rs2_bypass;
    logic signed [31:0] rd_data_m;
    
    always_ff @ (posedge clk) begin
        if(rd_v) register[rd] <= rd_data;
        rs1_rdata <= register[rs1];
        rs2_rdata <= register[rs2];
    end

    assign rs1_data = (rs1_bypass) ? rd_data_m : rs1_rdata;
    assign rs2_data = (rs2_bypass) ? rd_data_m : rs2_rdata;

    always_ff @ (posedge clk) begin
        rs1_bypass <= (rs1 == rd) & rd_v;
        rs2_bypass <= (rs2 == rd) & rd_v;
        if (rd_v) rd_data_m <= rd_data;
    end

endmodule
