/* verilator lint_off UNUSEDSIGNAL */

module execution
    import instruction_pkg::*;
(
    input clk,
    input reset,
    input logic [31:0] pc_i,
    input logic inst_v_i,
    input logic [31:0] inst_i,
    output logic pc_v_x,
    output logic [31:0] pc_x
);

    logic signed [31:0] pc_d;
    logic inst_v_x;
    logic [31:0] inst_x;

    always_ff @ (posedge clk) begin
        if (reset) begin
            inst_v_x <= 1'b0;
        end else begin
            inst_v_x <= inst_v_i;
        end
        if (inst_v_i) begin
            inst_x <= inst_i;
            pc_d <= pc_i;
        end
    end

    wire [4:0] opcode = inst_x[6:2];
    wire [6:0] funct7 = inst_x[31:25];
    wire [2:0] funct3 = inst_x[14:12];
    wire [4:0] rs1 = inst_i[19:15];
    wire [4:0] rs2 = inst_i[24:20];
    wire [4:0] rd = inst_x[11:7];
    wire signed [11:0] i_imm = inst_x[31:20];
    wire signed [12:0] b_imm = {inst_x[31],inst_x[7],inst_x[30:25],inst_x[11:8],1'b0};
    wire signed [31:0] u_imm = {inst_x[31:12],12'b0};
    wire signed [20:0] j_imm = {inst_x[31],inst_x[19:12],inst_x[20],inst_x[30:21],1'b0};

    logic signed [31:0] register [0:31];
    logic signed [31:0] rs1_rdata;
    logic signed [31:0] rs1_data;
    logic rs1_bypass;
    logic signed [31:0] rs2_rdata;
    logic signed [31:0] rs2_data;
    logic rs2_bypass;
    logic rd_v;
    wire  rd_v_x = (rd != 0);
    logic signed [31:0] rd_data;
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

    always_comb begin
        alu_a = 33'hx;
        alu_b = 33'hx;
        alu_m = 1'hx;
        sha = 1'bx;
        cmp_a = 32'hx;
        cmp_b = 32'hx;
        rd_v = 1'b0;
        rd_data = 32'hx;
        pc_v_x = 1'b0;
        pc_x = 32'hx;
        if(inst_v_x) begin
            case(opcode)
                OP:begin
                    alu_a = rs1_data;
                    alu_b = rs2_data;
                    rd_v = rd_v_x;
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
                    alu_b = 32'(signed'(i_imm));
                    rd_v = rd_v_x;
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
                    rd_v = rd_v_x;
                    rd_data = alu_o;
                end
                LUI:begin
                    alu_a = 0;
                    alu_b = u_imm;
                    alu_m = 1'b0;
                    rd_v = rd_v_x;
                    rd_data = alu_o;
                end
                JALR:begin
                    alu_a = rs1_data;
                    alu_b = i_imm;
                    alu_m = 1'b0;
                    rd_v = rd_v_x;
                    rd_data = pc_d + 4;
                    pc_x = alu_o;
                    pc_v_x = 1'b1;
                end
                JAL:begin
                    alu_a = pc_d;
                    alu_b = j_imm;
                    alu_m = 1'b0;
                    rd_v = rd_v_x;
                    rd_data = pc_d + 4;
                    pc_x = alu_o;
                    pc_v_x = 1'b1;
                end
                default: ;
            endcase
        end
    end
    
endmodule
