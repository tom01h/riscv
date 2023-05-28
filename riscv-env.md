.bashrc
```
export PATH="$PATH":/opt/riscv32/bin
export RISCV=/opt/riscv32
```

準備
```
sudo mkdir /opt/riscv32
sudo chmod 777 /opt/riscv32
sudo apt install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain/
sudo apt install device-tree-compiler
```

GCC
```
./configure --prefix=/opt/riscv32 --with-arch=rv32i --with-abi=ilp32
make
```

spike
```
git submodule update spike
cd spike
mkdir build
cd build
../configure --prefix=$RISCV --enable-commitlog  --without-boost --without-boost-asio --without-boost-regex
make
make install
```

pk
```
git submodule update pk
cd pk
../configure  --prefix=$RISCV --with-arch=rv32g --host=riscv32-unknown-elf
make
make install
```

hello.c
```
#include <stdio.h>

main(){
        printf("Hello\n");
}
```


test
```
riscv32-unknown-elf-gcc -o hello hello.c
spike --isa=rv32i /opt/riscv32/riscv32-unknown-elf/bin/pk hello
bbl loader
Hello

(riscv32-unknown-elf-objdump -d hello)
(spike -l --log=log_file --isa=rv32i /opt/riscv32/riscv32-unknown-elf/bin/pk hello)
```

riscv-tests
```
git clone https://github.com/riscv-software-src/riscv-tests
./configure --prefix=$RISCV/target --with-xlen=32
make isa
make install

diff Makefile Makefile.new
15c15
< all: benchmarks isa
---
> all: isa
19d18
<       install -d $(instbasedir)/share/riscv-tests/benchmarks
21d19
<       install -p -m 644 `find benchmarks -maxdepth 1 -type f` $(instbasedir)/share/riscv-tests/benchmarks
```

例えばrv32ui-p-add.dump  
```
80000688 <pass>:
80000688:       0ff0000f                fence
```
なので、PCが80000688に到達するとpass  
```
spike -l --log=log_file --isa=rv32i rv32ui-p-add
```
log_fileをみると
```
core   0: 0x80000688 (0x0ff0000f) fence   iorw,iorw
```
