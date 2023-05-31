/* verilator lint_off UNUSEDSIGNAL */
module trace
    import instruction_pkg::*;
(
    input clk,
    input reset,
    input valid,
    input [31:0] pc,
    input [31:0] inst,
    input rdv,
    input [4:0] rd_x,
    input [31:0] rd_data,
    input pcv,
    input [31:0] pc_x
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
    wire signed [12:0] b_imm = {inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
    wire signed [31:0] u_imm = {inst[31:12],12'b0};

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
                                asm={"add     x", reg_d, ", x", reg_s1, ", x ", reg_s2};
                            end
                            SUB_7:begin
                                asm={"sub     x", reg_d, ", x", reg_s1, ", x ", reg_s2};
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
                    default:begin
                        asm="Unimplemented";
                    end
                endcase
            end
            BRANCH:begin
                case(funct3)
                    BNE:begin
                        immediate.itoa(b_imm);
                        asm={"bne     x", reg_d, ", x", reg_s1, ", pc + ", immediate};
                    end
                    default:begin
                        asm="Unimplemented";
                    end
                endcase
            end
            LUI:begin
                immediate.itoa(u_imm);
                asm={"lui     x", reg_d, ", ", immediate};
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
                $write("x%2d <= 0x%08x", rd_x, rd_data);
            end    
            if (pcv) begin
                $write("PC  <= 0x%08x", pc_x);
            end    
            if (valid | rdv | pcv) begin
                $display("");
            end
        end
    end

endmodule
