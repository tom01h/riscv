rm -r log/
mkdir log/

for t in "${@}"; do
    echo -n "$t : "
    hexdump ../isa/$t -s 4096 -n 4096 -v -e '1/4 "%08X\n"' > inst.hex

    spike -l --log=log/$t.spike.log --isa=rv32i ../isa/$t

    reset=`grep "<test_2>:" ../isa/$t.dump | sed "s#\ .*##"`
    pass=`grep "<pass>:" ../isa/$t.dump | sed "s#\ .*##"`
    fail=`grep "<fail>:" ../isa/$t.dump | sed "s#\ .*##"`

    #./obj_dir/Vtop +trace +reset_pc=$reset +fail_pc=$fail +pass_pc=$pass > $t.log
    ./obj_dir/Vtop +reset_pc=$reset +fail_pc=$fail +pass_pc=$pass > log/$t.log
    mv konata.log log/$t.konata.log
    grep -e PASS -e FAIL log/$t.log
done