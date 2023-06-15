# 合成方法
Windows用の `GOWIN FPGA Designer` を使っています
## 準備
- `rtl_v` で `./gen.sh` して生成したVerilogファイルのうち `itcm.v, dtcm.v` 以外を `TangNano20k/riscv_core/src/` にコピーする
    - `itcm.v, dtcm.v` は変更を入れているので変更後を置いてある
- `firm` で `Make` して生成したファイル `inst.hex, data.hex` の最初に以下を付け足して `inst.mi, data.mi` として `TangNano20k/riscv_core/src/` にコピーする

    ```
    #File_format=Hex
    #Address_depth=1024
    #Data_width=32
    ```

## 合成
- GOWIN FPGA Designer でプロジェクトを開く
- `Open Project...` → `TangNano20k/riscv_core/` 以下にある `riscv_core.gprj` を開く
- `IP Core Generator` の `Open IP config file` で `TangNano20k/riscv_core/src/imem/imem.ipc` を開く
    - `TangNano20k/riscv_core/src/imem/imem.v` ができる
- 本当は `TangNano20k/riscv_core/src/dmem/dmem.v` も同様に生成するのだが、手で変更を入れているので変更後を置いてある
    - `input [3:0] wen;` に関する変更が入っている
    - プログラムを変更したときは `imem` と同じ方法で生成してから手で修正する
- `Synthesie` → `Place & Route` → `Program Device`