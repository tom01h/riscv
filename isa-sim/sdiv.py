import sys

Len = 8

A = int(sys.argv[1])
B = int(sys.argv[2]) << Len

Q   = 0
REM = A

divisor = B if A*B>=0 else -B # 1サイクル

QSIGN = 1 if A*B>=0 else -1
RSIGN = A < 0

for i in range(Len):
    Q   <<= 1
    REM <<= 1
    alu_l = REM - divisor
    if (alu_l >= 0 and not RSIGN) or ((alu_l < 0  or REM == divisor) and RSIGN):
        Q   += 1
        REM = alu_l

    #print(i, REM>>32, B>>32, Q, hex(REM if REM>=0 else (1<<64)+REM))

B   >>= Len
REM >>= Len

Q *= QSIGN # 1サイクル

#この2つは回路ではない
if Q == ((1<<Len) -1):
    Q=-1
#if Q == 1<<(Len-1):
#    Q=-Q

if (B==0) and (Q==-1) and (REM == A):
    print('Correct')
elif (A == Q * B + REM) and (abs(REM) < abs(B)) and (abs(REM) >= 0) and (REM*A >=0):
    print('Correct')
else:
    print('Incorrect')

print('{} / {} : Q={}, REM={}'.format(A , B, Q, REM))
