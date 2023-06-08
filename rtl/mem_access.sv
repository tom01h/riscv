/* verilator lint_off UNUSEDSIGNAL */

module mem_access
(
    input logic clk,
    //input logic reset,
    input logic [3:0] minst,
    input logic rdx_v,
    input logic signed [31:0] rd_data_x,
    output logic signed [31:0] rd_data_m,
    output logic dtcm_en,
    output logic [31:0] dtcm_addr,
    input logic [31:0] dtcm_rdata
);

    assign dtcm_en = (minst[3:2] != 2'b11);
    assign dtcm_addr = rd_data_x;

    logic rdx_v_m;
    logic signed [31:0] rd_data_l;
    assign rd_data_m = (rdx_v_m) ? rd_data_l : dtcm_rdata;
    
    always_ff @ (posedge clk) begin
        rdx_v_m <= rdx_v;
        if (rdx_v) begin
            rd_data_l <= rd_data_x;
        end
    end
endmodule
