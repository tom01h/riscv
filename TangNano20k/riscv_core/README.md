# 合成方法
Windows用の `GOWIN FPGA Designer` を使っています

## クロック
27MHz OSCじゃなくて AUX_PLL (MS5351M) を使っています
```
IO_LOC "clk_i" 10;
```
[これ](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/example/unbox.html#pll_clk)に従って周波数を設定する
```
Ctrl-x
Ctrl-c
Enter

TangNano20K />pll_clk O0=27M -s
target_freq = 27000000, (29,660213,1048575) (0)

```

## 準備
- `rtl/` のファイルのうち `itcm.sv, dtcm.sv` 以外を `TangNano20k/riscv_core/src/` にコピーする
    - `itcm.v, dtcm.v` は変更を入れているので変更後を置いてある
    - PLLを追加するために `cpu.sv` の先頭を下のように変更する
    ```
    module cpu
    (
        input logic clk_i,
        input logic reset,
        output logic [5:0] gpio_data
    );

        wire clk;
        Gowin_rPLL RPLL(
            .clkout(clk), //output clkout
            .clkin(clk_i) //input clkin
        );
    ```
- `firm/` で `Make` して生成したファイル `inst.hex, data.hex` の最初に以下を付け足して `inst.mi, data.mi` として `TangNano20k/riscv_core/src/` にコピーする

    ```
    #File_format=Hex
    #Address_depth=1024
    #Data_width=32
    ```

## 合成
- GOWIN FPGA Designer でプロジェクトを開く
- `Open Project...` → `TangNano20k/riscv_core/` 以下にある `riscv_core.gprj` を開く
- `IP Core Generator` の `Open IP config file` で `TangNano20k/riscv_core/src/gowin_rpll/gowin_rpll.ipc` を開く
    - `TangNano20k/riscv_core/src/gowin_rpll/gowin_rpll.v` ができる
- `IP Core Generator` の `Open IP config file` で `TangNano20k/riscv_core/src/imem/imem.ipc` を開く
    - `TangNano20k/riscv_core/src/imem/imem.v` ができる
- 本当は `TangNano20k/riscv_core/src/dmem/dmem.v` も同様に生成するのだが、手で変更を入れているので変更後を置いてある
    - `input [3:0] wen;` に関する変更が入っている
    - プログラムを変更したときは `imem` と同じ方法で生成してから手で修正する
- `Synthesie` → `Place & Route` → `Program Device`