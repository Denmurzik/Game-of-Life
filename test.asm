    asect 0xf3

IOReg: 
    asect 0xf0
stack:
    asect 0x00
start:
    ldi r0, stack
    stsp r0
    ldi r0, IOReg
    ldi r1, 0xff
    push r1
    push r1
    

end
halt