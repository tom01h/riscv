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
    input logic [2:0] div_inst, // [0] : signed / [1]: unsigned / [2] : signed div
    output logic stall_i,
    output logic hazard_x,
    output logic div_wb,
    input logic signed [31:0] rd_data_x,
    input logic signed [31:0] rd_data_m,
    input logic signed [33:0] alu_l,
    input logic eq_o,
    output logic RSIGN,
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

    wire signed [31:0] rs1_data_i = (rs1_bypass_x) ? rd_datax_m : ((rs1_bypass_m) ? rd_data_w : rs1_rdata);
    wire signed [31:0] rs2_data_i = (rs2_bypass_x) ? rd_datax_m : ((rs2_bypass_m) ? rd_data_w : rs2_rdata);

    logic QSIGN;
    always_ff @ (posedge clk) begin
        if(div_inst[0])      RSIGN <= rs1_data_i[31];
        else if(div_inst[1]) RSIGN <= 1'b0;
        if(div_inst[2])         QSIGN <= (rs1_data_i[31]^rs2_data_i[31]) & ~eq_o; // (rs2_data_i!=0)
        else if(|div_inst[1:0]) QSIGN <= 1'b0;
    end
    logic div_run;
    logic div_last;
    logic div_fin;
    logic signed [63:0] REM;
    logic signed [31:0] Q;
    assign div_wb = div_last&~QSIGN|div_fin&QSIGN;
    //sdiv.pyのこの部分
    //alu_l = REM - divisor
    //if (alu_l >= 0 and not RSIGN) or ((alu_l < 0  or REM == divisor) and RSIGN):
    //部分剰余が0を超えないことを検出しているが負または0検出には差(alu_l)の符号と一致検出器(とALL0検出)を使っている
    wire Qi = (~alu_l[33]&~RSIGN) | ((alu_l[33] | (eq_o&(REM[31:0]==0)))&RSIGN);
    wire [31:0] Qt = (div_fin) ? alu_l[31:0] : ((Qi) ? {Q[30:0],1'b1} : {Q[30:0],1'b0}); // (div_fin) ? alu_l[31:0] はQの符号反転
    assign Qo = Qt;
    always_ff @ (posedge clk) begin
        if(div_inst[0])            REM <= {63'(rs1_data_i), 1'b0};
        else if (div_inst[1])      REM <= {31'h0, rs1_data_i, 1'b0};
        else if(div_run|div_last)
            if(Qi)                 REM <= {alu_l[30:0], REM[31:0],1'b0};
            else                   REM <= {REM[62:0], 1'b0};

        if(|div_inst)             Q <= 0;
        else if(div_run|div_last) Q <= Qt;
    end
    logic signed [31:0] divisor;
    always_ff @ (posedge clk) begin
        if(div_inst[0])
            if(rs1_data_i[31]^rs2_data[31])  divisor <= alu_l[31:0]; //-rs2_data
            else                             divisor <= rs2_data;
        else if (div_inst[1])                divisor <= rs2_data;
    end

    assign rs1_data = (div_fin) ? 0 : ((div_inst[0]) ? 32'h0      : ((div_run|div_last) ? REM[63:32] : rs1_data_i));
    assign rs2_data = (div_fin) ? Q : ((div_inst[0]) ? rs2_data_i : ((div_run|div_last) ? divisor    : rs2_data_i));
    
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
        else if(|div_inst)      div_count <= 1;
        else if(div_count != 0) div_count <= div_count +1;
        else                    div_count <= 0;
    end

    assign div_run = (div_count != 0);
    always_ff @ (posedge clk) begin
        div_last <= div_run & (div_count==31);
        div_fin  <= div_last & QSIGN;
    end

    assign stall_i = hazard_x | (|div_inst) | div_run | div_last&QSIGN;
    assign hazard_x = rs1_hazard_x | rs2_hazard_x;

endmodule
