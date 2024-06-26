# RTLシミュレーション

## 準備
### [Verilator](https://verilator.org/guide/latest/install.html)
```
git clone https://github.com/verilator/verilator
cd verilator
autocon
./configure
make
sudo make install
```

## シミュレーション実行

例えばriscv-testsから作ったrv32ui-p-addiを実行するなら…

rv32ui-p-addi.dumpを見て`+reset_pc=018c +fail_pc=0414 +pass_pc=0430`を決める  
これは↓の例
```
80000188:       30200073                mret

8000018c <test_2>:
8000018c:       00200193                li      gp,2
略
80000414 <fail>:
80000414:       0ff0000f                fence
略
80000430 <pass>:
80000430:       0ff0000f                fence
```
命令をシミュレータの読める形式に変換する
```
isa-sim/にて
hexdump ../isa/rv32ui-p-addi -s 4096 -n 4096 -v -e '1/4 "%08X\n"' > inst.hex
```
コンパイル＆実行
```
isa-sim/にて
make
./obj_dir/Vtop +trace +reset_pc=018c +fail_pc=0414 +pass_pc=0430
```
Spikeを流すなら
```
isa-sim/にて
spike -l --log=log_file --isa=rv32im_zicsr_zifencei ../isa/rv32ui-p-addi
```

### ↑をまとめて実行する
`isa-sim/` と同じ階層の `isa/` に `risv-tests/isa/` の結果を準備して
```
isa-sim/にて
./run.sh テスト名の羅列
(例えば  ./run.sh rv32ui-p-add rv32ui-p-addi)
```

## Verilogに変換してからシミュレーション

### sv2v
変換は[これ](https://github.com/zachjs/sv2v)使った
```
rtl_v/にて (~/work/sv2v/sv2vの部分は適当に書き換えてね)
./gen.sh
```
コンパイル
```
isa-sim/にて
make -f Makefile_v
```