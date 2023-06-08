/* verilator lint_off UNUSEDSIGNAL */

module ireg
(
    input logic clk,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic rs1_v,
    input logic rs2_v,
    input logic rdx_v,
    input logic rdm_v,
    output logic stall_i,
    output logic hazard_x,
    input logic signed [31:0] rd_data_x,
    input logic signed [31:0] rd_data_m,
    output logic signed [31:0] rs1_data,
    output logic signed [31:0] rs2_data
);

    logic signed [31:0] register [0:31];
    logic signed [31:0] rs1_rdata;
    logic rs1_bypass_m;
    logic rs1_bypass_x;
    logic signed [31:0] rs2_rdata;
    logic rs2_bypass_m;
    logic rs2_bypass_x;
    logic signed [31:0] rd_data_w;
    
    always_ff @ (posedge clk) begin
        if(rdm_v_m) register[rd_m] <= rd_data_m;
        rs1_rdata <= register[rs1];
        rs2_rdata <= register[rs2];
    end

    assign rs1_data = (rs1_bypass_x) ? rd_data_m : ((rs1_bypass_m) ? rd_data_w : rs1_rdata);
    assign rs2_data = (rs2_bypass_x) ? rd_data_m : ((rs2_bypass_m) ? rd_data_w : rs2_rdata);

    logic [4:0] rd_m;
    logic rdm_v_m;

    always_ff @ (posedge clk) begin
        rs1_bypass_m <= (rs1 == rd_m) & rdm_v_m;
        rs2_bypass_m <= (rs2 == rd_m) & rdm_v_m;
        rs1_bypass_x <= (rs1 == rd)   & rdx_v;
        rs2_bypass_x <= (rs2 == rd)   & rdx_v;
        rdm_v_m <= rdm_v;
        if (rdm_v) begin
            rd_m <= rd;
        end
        if (rdm_v_m) rd_data_w <= rd_data_m;
    end

    logic rs1_hazard_x;
    logic rs2_hazard_x;
    always_ff @ (posedge clk) begin
        rs1_hazard_x <= (rs1 == rd) & !rdx_v & rdm_v & rs1_v;
        rs2_hazard_x <= (rs2 == rd) & !rdx_v & rdm_v & rs2_v;
    end

    assign stall_i = hazard_x;
    assign hazard_x = rs1_hazard_x | rs2_hazard_x;

endmodule
