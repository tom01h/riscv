/* verilator lint_off UNUSEDSIGNAL */

module execution
    import instruction_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic [31:0] pc_i,
    input logic inst_v_i,
    input logic hazard_x,
    input logic [31:0] inst_i,
    output logic pc_v_x,
    output logic [31:0] pc_x,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic rs1_v,
    output logic rs2_v,
    output logic rdx_v,
    output logic rdm_v,
    output logic [3:0] minst,
    output logic signed [31:0] rd_data,
    input logic signed [31:0] rs1_data,
    input logic signed [31:0] rs2_data
);

    logic signed [31:0] pc_d;
    logic inst_v_x;
    logic [31:0] inst_x;

    always_ff @ (posedge clk) begin
        if (reset) begin
            inst_v_x <= 1'b0;
        end else if(!hazard_x) begin
            inst_v_x <= inst_v_i;
        end
        if (inst_v_i & !hazard_x) begin
            inst_x <= inst_i;
            pc_d <= pc_i;
        end
    end

    assign rs1 = (hazard_x) ? inst_x[19:15] : inst_i[19:15];
    assign rs2 = (hazard_x) ? inst_x[24:20] : inst_i[24:20];
    assign rd = inst_x[11:7];
    wire  rd_v_x = (rd != 0);

    wire [4:0] opcode = inst_x[6:2];
    wire [6:0] funct7 = inst_x[31:25];
    wire [2:0] funct3 = inst_x[14:12];
    wire signed [11:0] i_imm = inst_x[31:20];
    wire signed [12:0] b_imm = {inst_x[31],inst_x[7],inst_x[30:25],inst_x[11:8],1'b0};
    wire signed [31:0] u_imm = {inst_x[31:12],12'b0};
    wire signed [20:0] j_imm = {inst_x[31],inst_x[19:12],inst_x[20],inst_x[30:21],1'b0};

    /* verilator lint_off WIDTHEXPAND */
    logic signed [32:0] alu_a;
    logic signed [32:0] alu_b;
    logic alu_m;
    logic signed [31:0] alu_o;
    logic signed [33:0] alu_l;
    
    assign alu_l = (alu_m) ? (alu_a  - alu_b) : (alu_a + alu_b);
    assign alu_o = alu_l[31:0];

    logic [4:0] shamt;
    logic sha;
    logic signed [31:0] shift_l;
    logic signed [31:0] shift_r;
    assign shamt = alu_b[4:0];
    
    assign shift_l = rs1_data << shamt;
    assign shift_r = (sha) ? (rs1_data >>> shamt) : (rs1_data >> shamt);

    logic signed [31:0] cmp_a;
    logic signed [31:0] cmp_b;
    logic eq_o;
    logic lt_o;

    assign eq_o = (cmp_a == cmp_b);
    assign lt_o = alu_l[33];

    logic signed [31:0] br_pc;
    assign br_pc = pc_d + b_imm;

    logic signed [31:0] link_pc;
    assign link_pc = pc_d + 4;

    always_comb begin
        alu_a = 33'hx;
        alu_b = 33'hx;
        alu_m = 1'hx;
        sha = 1'bx;
        cmp_a = 32'hx;
        cmp_b = 32'hx;
        rs1_v = 1'b0;
        rs2_v = 1'b0;
        rdx_v = 1'b0;
        rdm_v = 1'b0;
        minst = 4'b11xx;
        rd_data = 32'hx;
        pc_v_x = 1'b0;
        pc_x = 32'hx;
        if(inst_v_x & !hazard_x) begin
            case(opcode)
                OP:begin
                    alu_a = rs1_data;
                    alu_b = rs2_data;
                    rs1_v = 1'b1;
                    rs2_v = 1'b1;
                    rdx_v = rd_v_x;
                    rdm_v = rd_v_x;
                    case(funct3)
                        ADD_SUB:begin
                            case(funct7)
                                ADD_7: alu_m = 1'b0;
                                SUB_7: alu_m = 1'b1;
                                default: ;
                            endcase
                            rd_data = alu_o;
                        end
                        SLT:begin
                            alu_m = 1'b1;
                            rd_data = {31'h0, lt_o};
                        end
                        SLTU:begin
                            alu_m = 1'b1;
                            alu_a[32] = 1'b0; // unsigned
                            alu_b[32] = 1'b0; // unsigned
                            rd_data = {31'h0, lt_o};
                        end
                        SLL:begin
                            rd_data = shift_l;
                        end
                        SRL_SRA:begin
                            case(funct7)
                                SRL_7: sha = 1'b0;
                                SRA_7: sha = 1'b1;
                                default: ;
                            endcase                        
                            rd_data = shift_r;
                        end    
                        default: ;
                    endcase
                end
                OPIMM:begin
                    alu_a = rs1_data;
                    rs1_v = 1'b1;
                    alu_b = 32'(signed'(i_imm));
                    rdx_v = rd_v_x;
                    rdm_v = rd_v_x;
                    case(funct3)
                        ADDI:begin
                            alu_m = 1'b0;
                            rd_data = alu_o;
                        end
                        SLTI:begin
                            alu_m = 1'b1;
                            rd_data = {31'h0, lt_o};
                        end
                        SLTIU:begin
                            alu_m = 1'b1;
                            alu_a[32] = 1'b0; // unsigned
                            alu_b[32] = 1'b0; // unsigned
                            rd_data = {31'h0, lt_o};
                        end
                        SLLI:begin
                            rd_data = shift_l;
                        end    
                        SRLI_SRAI:begin
                            case(funct7)
                                SRLI_7: sha = 1'b0;
                                SRAI_7: sha = 1'b1;
                                default: ;
                            endcase
                            rd_data = shift_r;
                        end
                        default: ;
                    endcase
                end
                BRANCH:begin
                    alu_a = rs1_data;
                    alu_b = rs2_data;
                    rs1_v = 1'b1;
                    rs2_v = 1'b1;
                    pc_x = br_pc;
                    case(funct3)
                        BEQ: begin
                            pc_v_x = eq_o;
                            cmp_a = rs1_data;
                            cmp_b = rs2_data;
                        end
                        BNE: begin
                            pc_v_x = !eq_o;
                            cmp_a = rs1_data;
                            cmp_b = rs2_data;
                        end
                        BLT: begin
                            alu_m = 1'b1;
                            pc_v_x = lt_o;
                        end
                        BGE: begin
                            alu_m = 1'b1;
                            pc_v_x = !lt_o;
                        end
                        BLTU: begin
                            alu_m = 1'b1;
                            pc_v_x = lt_o;
                            alu_a[32] = 1'b0; // unsigned
                            alu_b[32] = 1'b0; // unsigned
                        end
                        BGEU: begin
                            alu_m = 1'b1;
                            pc_v_x = !lt_o;
                            alu_a[32] = 1'b0; // unsigned
                            alu_b[32] = 1'b0; // unsigned
                        end
                        default: ;
                    endcase
                end
                AUIPC:begin
                    alu_a = pc_d;
                    alu_b = u_imm;
                    alu_m = 1'b0;
                    rdx_v = rd_v_x;
                    rdm_v = rd_v_x;
                    rd_data = alu_o;
                end
                LUI:begin
                    alu_a = 0;
                    alu_b = u_imm;
                    alu_m = 1'b0;
                    rdx_v = rd_v_x;
                    rdm_v = rd_v_x;
                    rd_data = alu_o;
                end
                JALR:begin
                    alu_a = rs1_data;
                    rs1_v = 1'b1;
                    alu_b = i_imm;
                    alu_m = 1'b0;
                    rdx_v = rd_v_x;
                    rdm_v = rd_v_x;
                    rd_data = link_pc;
                    pc_x = alu_o;
                    pc_v_x = 1'b1;
                end
                JAL:begin
                    alu_a = pc_d;
                    alu_b = j_imm;
                    alu_m = 1'b0;
                    rdx_v = rd_v_x;
                    rdm_v = rd_v_x;
                    rd_data = link_pc;
                    pc_x = alu_o;
                    pc_v_x = 1'b1;
                end
                LOAD:begin
                    alu_a = rs1_data;
                    rs1_v = 1'b1;
                    alu_b = i_imm;
                    alu_m = 1'b0;
                    rdx_v = 1'b0;
                    rdm_v = rd_v_x;
                    rd_data = alu_o;
                    minst = {1'b0, LW};
                end
                default: ;
            endcase
        end
    end
    
endmodule
