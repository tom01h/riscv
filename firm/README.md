# Tang Nano 20K で動かすLEDテストのファーム
## シミュレーションは
makeした後にinst.hexとdata.hexをisa-sim/にコピーして
```
./obj_dir/Vtop +trace +reset_pc=80000000 +pass_pc=80000014
```

LEDの点灯パターンは`gpio_data`を使う

## FPGAにもっていくときは
- `DELAY`を大きくしてゆっくり動くようにする
- `LOOPCOUNT`を大きくして繰り返し回数を増やす（または最外ループを無限ループに）