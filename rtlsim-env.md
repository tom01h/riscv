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
spike -l --log=log_file --isa=rv32i ../isa/rv32ui-p-addi
```