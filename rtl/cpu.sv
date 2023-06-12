/* verilator lint_off UNUSEDSIGNAL */

module cpu
(
    input logic clk,
    input logic reset,
    output logic [5:0] gpio_data
);
    logic reset_p, reset_d;
    always_ff @ (posedge clk)
        reset_d <= reset;
    assign reset_p = reset | reset_d;

    logic stall_i;
    logic hazard_x;

    logic inst_v_i;
    logic [31:0] pc_p;
    logic [31:0] pc_i;
    logic [31:0] pc_x;

    logic pc_v_x;

    instruction instruction
    (
        .clk      (clk),
        .reset    (reset_p),
        .stall_i  (stall_i),
        .inst_v_i (inst_v_i),
        .pc_p     (pc_p),
        .pc_i     (pc_i),
        .pc_v_x   (pc_v_x),
        .pc_x     (pc_x)
    );

    logic [31:0] inst_i;
    
    itcm itcm
    (
        .clk      (clk),
        .pc_p     (pc_p),
        .inst_i   (inst_i)
    );

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic rs1_v;
    logic rs2_v;
    logic rdx_v;
    logic rdm_v;
    logic [3:0] minst;
    logic signed [31:0] rd_data_x;
    logic signed [31:0] rs1_data;
    logic signed [31:0] rs2_data;

    execution execution
    (
        .clk      (clk),
        .reset    (reset_p),
        .pc_i     (pc_i),
        .inst_v_i (inst_v_i),
        .hazard_x  (hazard_x),
        .inst_i   (inst_i),
        .pc_v_x   (pc_v_x),
        .pc_x     (pc_x),
        .rs1      (rs1),
        .rs2      (rs2),
        .rd       (rd),
        .rs1_v    (rs1_v),
        .rs2_v    (rs2_v),
        .rdx_v    (rdx_v),
        .rdm_v    (rdm_v),
        .minst    (minst),
        .rd_data  (rd_data_x),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    logic signed [31:0] rd_data_m;

    ireg ireg
    (
        .clk       (clk),
        .rs1       (rs1),
        .rs2       (rs2),
        .rd        (rd),
        .rs1_v    (rs1_v),
        .rs2_v    (rs2_v),
        .rdx_v     (rdx_v),
        .rdm_v     (rdm_v),
        .stall_i   (stall_i),
        .hazard_x  (hazard_x),
        .rd_data_x (rd_data_x),
        .rd_data_m (rd_data_m),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );
    
        
    logic dtcm_en;
    logic [3:0] dtcm_wen;
    logic [31:0] dtcm_addr;
    logic [31:0] dtcm_rdata;
    logic [31:0] dtcm_wdata;
    
    mem_access mem_access
    (
        .clk        (clk),
        //.reset      (reset),
        .minst      (minst),
        .rdx_v      (rdx_v),
        .rs2_data_x (rs2_data),
        .rd_data_x  (rd_data_x),
        .rd_data_m  (rd_data_m),
        .dtcm_en    (dtcm_en),
        .dtcm_wen   (dtcm_wen),
        .dtcm_addr  (dtcm_addr),
        .dtcm_rdata (dtcm_rdata),
        .dtcm_wdata (dtcm_wdata)
    );
    
    logic memsel;
    logic memsel_w;
    logic [31:0] dtcm_rdata_w;
    
    assign memsel = (dtcm_addr[31:28] == 4'h9);
    assign dtcm_rdata = (memsel_w) ? {26'h0, gpio_data} : dtcm_rdata_w;
    always_ff @ (posedge clk) begin
        memsel_w <= memsel;
        if(reset)begin
            gpio_data <= 0;
        end else if(memsel)begin
            if(dtcm_wen[0]) gpio_data <= dtcm_wdata[5:0];
        end
    end
    
    dtcm dtcm
    (
        .clk      (clk),
        .addr     (dtcm_addr),
        .wen      (dtcm_wen & {4{!memsel}}),
        .data_o   (dtcm_rdata_w),
        .data_i   (dtcm_wdata)
    );
endmodule
