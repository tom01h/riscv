/* verilator lint_off UNUSEDSIGNAL */
module trace
    import instruction_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic valid,
    input logic [31:0] pc,
    input logic [31:0] inst,
    input logic rdv,
    input logic [4:0] rd_m,
    input logic [31:0] rd_data,
    input logic pcv,
    input logic [31:0] pc_x,
    input logic inst_v_i,
    input logic inst_v_x,
    input logic inst_v_m,
    input logic inst_v_r,
    input int ci,
    input int cx,
    input int cm,
    input int cr
);
    string space = "                                ";
    string asm;
    string reg_s1;
    string reg_s2;
    string reg_d;
    string immediate;
    wire [4:0] opcode = inst[6:2];
    wire [6:0] funct7 = inst[31:25];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];
    wire [4:0] rd = inst[11:7];
    wire signed [11:0] i_imm = inst[31:20];
    wire signed [11:0] s_imm = {inst[31:25],inst[11:7]};
    wire signed [12:0] b_imm = {inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
    wire signed [31:0] u_imm = {inst[31:12],12'b0};
    wire signed [20:0] j_imm = {inst[31],inst[19:12],inst[20],inst[30:21],1'b0};

    always_comb begin
        reg_s1.itoa(rs1);
        reg_s2.itoa(rs2);
        reg_d.itoa(rd);
        case(opcode)
            OP:begin
                case(funct3)
                    ADD_SUB:begin
                        case(funct7)
                            ADD_7:begin
                                asm={"add     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                            end
                            SUB_7:begin
                                asm={"sub     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                            end    
                            default:begin
                                asm="Unimplemented";
                            end
                        endcase
                    end
                    SLT:begin
                        asm={"slt     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                    end
                    SLTU:begin
                        asm={"sltu    x", reg_d, ", x", reg_s1, ", x", reg_s2};
                    end
                    XOR:begin
                        asm={"xor     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                    end
                    OR:begin
                        asm={"or      x", reg_d, ", x", reg_s1, ", x", reg_s2};
                    end
                    AND:begin
                        asm={"and     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                    end
                    SLL:begin
                        asm={"sll     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                    end
                    SRL_SRA:begin
                        case(funct7)
                            SRL_7:begin
                                asm={"srl     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                            end
                            SRA_7:begin
                                asm={"sra     x", reg_d, ", x", reg_s1, ", x", reg_s2};
                            end
                            default:begin
                                asm="Unimplemented";
                            end
                        endcase                        
                    end    
                    default:begin
                        asm="Unimplemented";
                    end
                endcase
            end
            OPIMM:begin
                case(funct3)
                    ADDI:begin
                        immediate.itoa(i_imm);
                        if(rd==0)         asm={"nop"};
                        else if(rs1==0  ) asm={"li      x", reg_d, ", ", immediate};
                        else if(i_imm==0) asm={"mv      x", reg_d, ", x", reg_s1};
                        else              asm={"addi    x", reg_d, ", x", reg_s1, ", ", immediate};
                    end
                    SLTI:begin
                        immediate.itoa(i_imm);
                        asm={"slti    x", reg_d, ", x", reg_s1, ", ", immediate};
                    end
                    SLTIU:begin
                        immediate.itoa(unsigned'(i_imm));
                        asm={"sltiu   x", reg_d, ", x", reg_s1, ", ", immediate};
                    end
                    XORI:begin
                        immediate.itoa(unsigned'(i_imm));
                        asm={"xori    x", reg_d, ", x", reg_s1, ", ", immediate};
                    end
                    ORI:begin
                        immediate.itoa(unsigned'(i_imm));
                        asm={"ori     x", reg_d, ", x", reg_s1, ", ", immediate};
                    end
                    ANDI:begin
                        immediate.itoa(unsigned'(i_imm));
                        asm={"andi    x", reg_d, ", x", reg_s1, ", ", immediate};
                    end
                    SLLI:begin
                        immediate.itoa(i_imm[4:0]);
                        asm={"slli    x", reg_d, ", x", reg_s1, ", ", immediate};
                    end
                    SRLI_SRAI:begin
                        case(funct7)
                            SRLI_7:begin
                                immediate.itoa(i_imm[4:0]);
                                asm={"srli    x", reg_d, ", x", reg_s1, ", ", immediate};
                            end
                            SRAI_7:begin
                                immediate.itoa(i_imm[4:0]);
                                asm={"srai    x", reg_d, ", x", reg_s1, ", ", immediate};
                            end
                            default:begin
                                asm="Unimplemented";
                            end
                        endcase                        
                    end    
                    default:begin
                        asm="Unimplemented";
                    end
                endcase
            end
            BRANCH:begin
                case(funct3)
                    BEQ:begin
                        immediate.itoa(b_imm);
                        asm={"beq     x", reg_s1, ", x", reg_s2, ", pc + ", immediate};
                    end
                    BNE:begin
                        immediate.itoa(b_imm);
                        asm={"bne     x", reg_s1, ", x", reg_s2, ", pc + ", immediate};
                    end
                    BLT:begin
                        immediate.itoa(b_imm);
                        asm={"blt     x", reg_s1, ", x", reg_s2, ", pc + ", immediate};
                    end
                    BGE:begin
                        immediate.itoa(b_imm);
                        asm={"bge     x", reg_s1, ", x", reg_s2, ", pc + ", immediate};
                    end
                    BLTU:begin
                        immediate.itoa(b_imm);
                        asm={"bltu    x", reg_s1, ", x", reg_s2, ", pc + ", immediate};
                    end
                    BGEU:begin
                        immediate.itoa(b_imm);
                        asm={"bgeu    x", reg_s1, ", x", reg_s2, ", pc + ", immediate};
                    end
                    default:begin
                        asm="Unimplemented";
                    end
                endcase
            end
            AUIPC:begin
                immediate.itoa(u_imm);
                asm={"auipc   x", reg_d, ", pc + ", immediate};
            end
            LUI:begin
                immediate.itoa(u_imm);
                asm={"lui     x", reg_d, ", ", immediate};
            end
            JALR:begin
                immediate.itoa(i_imm);
                asm={"jalr    x", reg_d, ", x", reg_s1, ", ", immediate};
            end
            JAL:begin
                immediate.itoa(j_imm);
                asm={"jal     x", reg_d, ", pc + ", immediate};
            end
            LOAD:begin
                immediate.itoa(i_imm);
                case(funct3)
                    LB:  asm={"lb      x", reg_d, ", ", immediate, "(x", reg_s1, ")"};
                    LH:  asm={"lh      x", reg_d, ", ", immediate, "(x", reg_s1, ")"};
                    LW:  asm={"lw      x", reg_d, ", ", immediate, "(x", reg_s1, ")"};
                    LBU: asm={"lbu     x", reg_d, ", ", immediate, "(x", reg_s1, ")"};
                    LHU: asm={"lhu     x", reg_d, ", ", immediate, "(x", reg_s1, ")"};
                    default: asm="Unimplemented";
                endcase
            end
            STORE:begin
                immediate.itoa(s_imm);
                case(funct3)
                    SB:  asm={"sb      x", reg_s2, ", ", immediate, "(x", reg_s1, ")"};
                    SH:  asm={"sh      x", reg_s2, ", ", immediate, "(x", reg_s1, ")"};
                    SW:  asm={"sw      x", reg_s2, ", ", immediate, "(x", reg_s1, ")"};
                    default: asm="Unimplemented";
                endcase
            end
            default:begin
                asm="Unimplemented";
            end    
        endcase
        asm = {asm, space};
    end

    always_ff @ (negedge clk) begin
        if (!reset) begin
            if (valid) begin
                $write("0x%08x (0x%08x)  %s/ ", pc, inst, asm.substr(0,30));
            end else if(rdv | pcv) begin
                $write("                                                        / ");
            end
            if (rdv) begin
                $write("x%2d <= 0x%08x", rd_m, rd_data);
            end    
            if (rdv & pcv) begin
                $write(" / ");
            end    
            if (pcv) begin
                $write("PC  <= 0x%08x", pc_x);
            end    
            if (valid | rdv | pcv) begin
                $display("");
            end
        end
    end

    int konata;

    initial begin
        konata = $fopen("konata.log", "w");
        $fdisplay(konata, "Kanata\t0004");
        $fdisplay(konata, "C=\t-1");
    end

    always_ff @ (negedge clk) begin
        if (!reset) begin
            if(inst_v_i)begin
                $fdisplay(konata, "I\t%d\t%d\t0", ci, ci);
                $fdisplay(konata, "S\t%d\t0\tI", ci);
                $fdisplay(konata, "L\t%d\t0\t(%08x) %s", ci, pc, asm.substr(0,30));
                $fdisplay(konata, "L\t%d\t1\tOP = %08x\\n", ci, inst);
            end    
            if(inst_v_x)begin
                $fdisplay(konata, "S\t%d\t0\tX", cx);
            end    
            if(inst_v_m)begin
                $fdisplay(konata, "S\t%d\t0\tM", cm);
            end    
            if (rdv) begin
                $fdisplay(konata, "L\t%d\t1\tx%2d <= 0x%08x\\n", cm, rd_m, rd_data);
            end    
            if(inst_v_r)begin
                $fdisplay(konata, "R\t%d\t%d\t0", cr, cr);
            end    
            $fdisplay(konata, "C\t1");
        end
    end

endmodule
