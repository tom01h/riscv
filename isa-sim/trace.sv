/* verilator lint_off UNUSEDSIGNAL */
module trace
    import instruction_pkg::*;
(
    input clk,
    input valid,
    input [31:0] pc,
    input [31:0] inst,
    input rdv,
    input [4:0] rd_x,
    input [31:0] rd_data

);
    string space = "                         ";
    string asm;
    string reg_s1;
    string reg_d;
    string immediate;
    wire [4:0] opcode = inst[6:2];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rd = inst[11:7];
    wire signed [11:0] i_imm = inst[31:20];

    always_comb begin
        case(opcode)
            OPIMM:begin
                case(funct3)
                    ADDI:begin
                        reg_s1.itoa(rs1);
                        reg_d.itoa(rd);
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
            default:begin
                asm="Unimplemented";
            end    
        endcase
        asm = {asm, space};
    end

    always_ff @ (posedge clk) begin
        if (valid) begin
            $write("0x%08x (0x%08x)  %s/ ", pc, inst, asm.substr(0,24));
        end else if(rdv) begin
            $write("                                                  / ");
        end
        if (rdv) begin
            $write("x%2d <= 0x%08x", rd_x, rd_data);
        end    
        if (valid | rdv) begin
            $display("");
        end
    end

endmodule
