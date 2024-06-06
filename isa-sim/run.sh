rm -r log/
mkdir log/

for t in "${@}"; do
    echo -n "$t : "
    hexdump ../isa/$t -s  4096 -n 4096 -v -e '1/4 "%08X\n"' > inst.hex
    hexdump ../isa/$t -s 12288 -n 4096 -v -e '1/4 "%08X\n"' > data.hex

    spike -l --log=log/$t.spike.log --isa=rv32im_zicsr_zifencei ../isa/$t

    reset=`grep "addi\s.*test_[0-9]*>" ../isa/$t.dump | sed "s/.*# //; s#\s.*##"`
    #reset=`grep "<test_2>:" ../isa/$t.dump | sed "s#\ .*##"`
    pass=`grep "<pass>:" ../isa/$t.dump | sed "s#\ .*##"`
    fail=`grep "<fail>:" ../isa/$t.dump | sed "s#\ .*##"`

    #./obj_dir/Vtop +trace +reset_pc=$reset +fail_pc=$fail +pass_pc=$pass > log/$t.log
    ./obj_dir/Vtop +reset_pc=$reset +fail_pc=$fail +pass_pc=$pass > log/$t.log
    mv konata.log log/$t.konata.log
    grep -e PASS -e FAIL log/$t.log
done
