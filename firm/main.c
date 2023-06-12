volatile char *Data = ((volatile char *)0x9a100008);

#define DELAY 10
#define LOOPCOUNT 2

int putc(char c)
{
    char tmp;
    for(int i = 0; i < DELAY; i++){
        tmp = *Data;
    }
    *Data = c;
    return tmp;
}

int main(void)
{
    int l;
    for(int k = 0; k < LOOPCOUNT; k++){
        for(int i = 1; i < 4; i++){
            l = ~(-1 << i);
            l &= 0xf;
            l <<= (9-i);
            for(int j = 0; j < 6+i; j++){
                putc((l>>8) & 0x3f);
                l = l << 1;
            }
            l = l >> 2;
            for(int j = 0; j < 6+i; j++){
                putc((l>>8) & 0x3f);
                l = l >> 1;
            }
        }
    }
}
