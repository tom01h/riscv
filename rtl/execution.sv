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

    logic [31:0] pc_d;
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
    wire [2:0] funct3 = inst_x[14:12];
    wire [4:0] rs1 = inst_i[19:15];
    wire [4:0] rs2 = inst_i[24:20];
    wire [4:0] rd = inst_x[11:7];
    wire signed [11:0] i_imm = inst_x[31:20];
    wire signed [12:0] b_imm = {inst_x[31],inst_x[7],inst_x[30:25],inst_x[11:8],1'b0};

    logic signed [31:0] imm;
    logic signed [31:0] alu_a;
    logic signed [31:0] alu_b;
    logic alu_c;
    logic signed [31:0] alu_o;
    wire eq_o = (rs1_data == rs2_data);
    
    logic [31:0] register [0:31];
    logic [31:0] rs1_rdata;
    logic [31:0] rs1_data;
    logic rs1_bypass;
    logic [31:0] rs2_rdata;
    logic [31:0] rs2_data;
    logic rs2_bypass;
    logic rd_v;
    wire  rd_v_x = (rd != 0);
    logic [31:0] rd_data;
    logic [31:0] rd_data_m;
    
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
    assign alu_o = alu_a + alu_b + alu_c;

    always_comb begin
        imm = 32'hx;
        alu_a = 32'hx;
        alu_b = 32'hx;
        alu_c = 1'hx;
        rd_v = 1'b0;
        rd_data = 32'hx;
        pc_v_x = 1'b0;
        pc_x = 32'hx;
        if(inst_v_x) begin
            case(opcode)
                OPIMM:begin
                    case(funct3)
                        ADDI:begin
                            imm = 32'(signed'(i_imm));
                            alu_a = rs1_data;
                            alu_b = imm;
                            alu_c = 1'b0;
                            rd_v = rd_v_x;
                            rd_data = alu_o;
                        end
                        default: ;
                    endcase
                end
                BRANCH:begin
                    case(funct3)
                        BNE:begin
                            imm = 32'(signed'(b_imm));
                            alu_a = pc_d;
                            alu_b = imm;
                            alu_c = 1'b0;
                            pc_v_x = !eq_o;
                            pc_x = alu_o;
                        end
                        default: ;
                    endcase
                end
                default: ;
            endcase
        end
    end
    
endmodule
