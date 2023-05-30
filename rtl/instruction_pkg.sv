package instruction_pkg;

parameter OPIMM = 5'b001_00;
parameter ADDI  = 3'b000;
//parameter SLTI  = 3'b010;
//parameter SLTIU = 3'b011;
//parameter XORI  = 3'b100;
//parameter ORI   = 3'b110;
//parameter ANDI  = 3'b111;

parameter BRANCH = 5'b110_00;
//parameter BEQ  = 3'b000;
parameter BNE  = 3'b001;
//parameter BLT  = 3'b100;
//parameter BGE  = 3'b101;
//parameter BLTU = 3'b110;
//parameter BGEU = 3'b111;

endpackage : instruction_pkg
