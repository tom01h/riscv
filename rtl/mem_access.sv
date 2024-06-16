/* verilator lint_off UNUSEDSIGNAL */
`default_nettype none

module mem_access
(
    input logic clk,
    //input logic reset,
    input logic [3:0] minst,
    input logic rdx_v,
    input logic signed [31:0] rs2_data_x,
    input logic signed [31:0] rd_data_x,
    output logic signed [31:0] rd_data_m,
    output logic dtcm_en,
    output logic [3:0] dtcm_wen,
    output logic [31:0] dtcm_addr,
    input logic [31:0] dtcm_rdata,
    output logic [31:0] dtcm_wdata
);

    assign dtcm_en = (minst[3:2] != 2'b11);
    assign dtcm_addr = rd_data_x;

    always_comb begin
        casez({minst, dtcm_addr[1:0]})
            6'b1000_00 : begin dtcm_wen = 4'h1; dtcm_wdata = {4{rs2_data_x[7:0]}}; end
            6'b1000_01 : begin dtcm_wen = 4'h2; dtcm_wdata = {4{rs2_data_x[7:0]}}; end
            6'b1000_10 : begin dtcm_wen = 4'h4; dtcm_wdata = {4{rs2_data_x[7:0]}}; end
            6'b1000_11 : begin dtcm_wen = 4'h8; dtcm_wdata = {4{rs2_data_x[7:0]}}; end
            6'b1001_0? : begin dtcm_wen = 4'h3; dtcm_wdata = {2{rs2_data_x[15:0]}}; end
            6'b1001_1? : begin dtcm_wen = 4'hc; dtcm_wdata = {2{rs2_data_x[15:0]}}; end
            6'b1010_?? : begin dtcm_wen = 4'hf; dtcm_wdata = rs2_data_x; end
            default : begin dtcm_wen = 4'h0; dtcm_wdata = 32'hx; end
        endcase
    end    

    wire dtcm_ld = (minst[3] == 1'b0);
    logic [3:0] minst_m;
    logic rdx_v_m;
    logic [1:0] dtcm_aln_addr;
    logic signed [31:0] dtcm_aln_data;
    logic signed [31:0] rd_data_l;

    assign rd_data_m = (rdx_v_m) ? rd_data_l : dtcm_aln_data;
    
    always_comb begin
        casez({minst_m, dtcm_aln_addr})
            6'b0000_00 : dtcm_aln_data = 32'(signed'(dtcm_rdata[ 0+:8]));
            6'b0000_01 : dtcm_aln_data = 32'(signed'(dtcm_rdata[ 8+:8]));
            6'b0000_10 : dtcm_aln_data = 32'(signed'(dtcm_rdata[16+:8]));
            6'b0000_11 : dtcm_aln_data = 32'(signed'(dtcm_rdata[24+:8]));
            6'b0001_0? : dtcm_aln_data = 32'(signed'(dtcm_rdata[ 0+:16]));
            6'b0001_1? : dtcm_aln_data = 32'(signed'(dtcm_rdata[16+:16]));
            6'b0010_?? : dtcm_aln_data = dtcm_rdata;
            6'b0100_00 : dtcm_aln_data = 32'(unsigned'(dtcm_rdata[ 0+:8]));
            6'b0100_01 : dtcm_aln_data = 32'(unsigned'(dtcm_rdata[ 8+:8]));
            6'b0100_10 : dtcm_aln_data = 32'(unsigned'(dtcm_rdata[16+:8]));
            6'b0100_11 : dtcm_aln_data = 32'(unsigned'(dtcm_rdata[24+:8]));
            6'b0101_0? : dtcm_aln_data = 32'(unsigned'(dtcm_rdata[ 0+:16]));
            6'b0101_1? : dtcm_aln_data = 32'(unsigned'(dtcm_rdata[16+:16]));
            default : dtcm_aln_data = 32'hx;
        endcase
    end    

    always_ff @ (posedge clk) begin
        if(dtcm_ld) begin
            minst_m <= minst;
            dtcm_aln_addr <= rd_data_x[1:0];
        end    
        rdx_v_m <= rdx_v;
        if (rdx_v) begin
            rd_data_l <= rd_data_x;
        end
    end
endmodule
