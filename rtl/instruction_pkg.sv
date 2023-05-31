package instruction_pkg;

parameter OP = 5'b01_100;

parameter ADD_SUB  = 3'b000;
//parameter SLT      = 3'b010;
//parameter SLTU     = 3'b011;
//parameter XOR      = 3'b100;
//parameter OR       = 3'b110;
//parameter AND      = 3'b111;
parameter SLL      = 3'b001;
parameter SRL_SRA  = 3'b101;
parameter ADD_7 = 7'b0000000;
parameter SUB_7 = 7'b0100000;
parameter SRL_7 = 7'b0000000;
parameter SRA_7 = 7'b0100000;

parameter OPIMM = 5'b00_100;
parameter ADDI      = 3'b000;
//parameter SLTI      = 3'b010;
//parameter SLTIU     = 3'b011;
//parameter XORI      = 3'b100;
//parameter ORI       = 3'b110;
//parameter ANDI      = 3'b111;
parameter SLLI      = 3'b001;
parameter SRLI_SRAI = 3'b101;
parameter SRLI_7 = 7'b0000000;
parameter SRAI_7 = 7'b0100000;


parameter BRANCH = 5'b11_000;
parameter BEQ  = 3'b000;
parameter BNE  = 3'b001;
//parameter BLT  = 3'b100;
//parameter BGE  = 3'b101;
//parameter BLTU = 3'b110;
//parameter BGEU = 3'b111;

parameter LUI = 5'b01_101;
endpackage : instruction_pkg
