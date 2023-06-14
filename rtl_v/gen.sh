for f in cpu.sv  dtcm.sv  execution.sv  instruction.sv  ireg.sv  itcm.sv  mem_access.sv; do
    echo $f
    ~/work/sv2v/sv2v ../rtl/$f ../rtl/instruction_pkg.sv > ${f%.sv}.v
done
