module trace
(
    input clk,
    input valid,
    input [31:0] pc,
    input [31:0] inst
);
    parameter OPIMM = 5'b001_00;
    parameter ADDI  = 3'b000;
    //parameter SLTI  = 3'b010;
    //parameter SLTIU = 3'b011;
    //parameter XORI  = 3'b100;
    //parameter ORI   = 3'b110;
    //parameter ANDI  = 3'b111;

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
    end

    always_ff @ (posedge clk) begin
        if (valid) begin
            $display("0x%08x (0x%08x)  %s", pc, inst, asm);
        end
    end

endmodule
