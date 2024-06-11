/* verilator lint_off UNUSEDSIGNAL */

module ireg
(
    input logic clk,
    input logic reset,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic rs1_v,
    input logic rs2_v,
    input logic rdx_v,
    input logic rdm_v,
    input logic div_inst,
    output logic stall_i,
    output logic hazard_x,
    output logic div_last,
    input logic signed [31:0] rd_data_x,
    input logic signed [31:0] rd_data_m,
    input logic signed [33:0] alu_l,
    output logic signed [31:0] Qo,
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
    logic signed [31:0] rd_datax_m;
    
    always_ff @ (posedge clk) begin
        if(rdm_v_m)  register[rd_m] <= rd_data_m;
        rs1_rdata <= register[rs1];
        rs2_rdata <= register[rs2];
    end

    logic div_run;
    logic [63:0] Q;
    wire [63:0] Qi = (alu_l[33]) ? {Q[62:0], 1'b0} : {alu_l[30:0], Q[31:0],1'b1};
    assign Qo = Qi[31:0];

    wire [31:0] rs1_data_i = (rs1_bypass_x) ? rd_datax_m : ((rs1_bypass_m) ? rd_data_w : rs1_rdata);
    assign rs2_data = (rs2_bypass_x) ? rd_datax_m : ((rs2_bypass_m) ? rd_data_w : rs2_rdata);

    assign rs1_data = (div_inst) ? {31'h0, rs1_data_i[31]} : ((div_run) ? Q[63:32] : rs1_data_i);

    always_ff @ (posedge clk) begin
        if(div_inst) begin
            if(alu_l[33]) Q <= {30'h0, rs1_data_i, 2'b0};
            else          Q <= {alu_l[30:0], rs1_data_i[30:0], 2'b01};
        end
        else if(div_run)  Q <= Qi;
    end
    
    logic [4:0] rd_m;
    logic rdm_v_m;

    always_ff @ (posedge clk) begin
        rs1_bypass_m <= (rs1 == rd_m) & rdm_v_m;
        rs2_bypass_m <= (rs2 == rd_m) & rdm_v_m;
        rs1_bypass_x <= (rs1 == rd)   & rdx_v;
        rs2_bypass_x <= (rs2 == rd)   & rdx_v;
        rdm_v_m <= rdm_v;
        if (rdx_v) begin
            rd_datax_m <= rd_data_x;
        end
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

    logic [4:0] div_count;

    always_ff @ (posedge clk) begin
        if(reset)               div_count <= 0;
        else if(div_inst)       div_count <= 1;
        else if(div_count != 0) div_count <= div_count +1;
        else                    div_count <= 0;
    end

    assign div_run = (div_count != 0);
    always_ff @ (posedge clk) begin
        div_last <= div_run & (div_count==30);
    end

    assign stall_i = hazard_x | div_inst | div_run;
    assign hazard_x = rs1_hazard_x | rs2_hazard_x;

endmodule
