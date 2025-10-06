.data
    table: .word 16,48,112,240,496,1008,2032,4048,8176,16368,32752,65520,131056,262128,524272
    pass_test: .string "All test passed"
    fail_test: .string "test fail"
.text
main:
    li t0,0        # t0: uft8
    li t1, 255

# a2 uf8->uint32
# a1 uint32->uf8

main_loop:
    bge t0, t1,end_main
    addi sp, sp, -8
    sw t0, 0 (sp)
    sw t1, 4 (sp)
    mv a0, t0
    jal uf8_decode
    jal uf8_encode
    lw t0,0(sp)
    lw t1,4(sp)
    addi sp,sp,8
    
    bne a0, t0, fail
    addi t0, t0,1
    la a0, pass_test 
    j main_loop

fail:
    la a0,pass_test
    li a7,4
    ecall
    
end_main:
    li a7, 4
    ecall
    li a7, 10
    ecall
    
uf8_decode:
    srli  t0, a0, 4         # e = b >> 4
    andi  t1, a0, 0x0F      # m = b & 0xF   
    addi  t1, t1, 16        # t1 = m + 16
    sll   t2, t1, t0        # t2 = (m+16) << e  = (m+16)*2^e
    addi  a0, t2, -16       # a0 = (m+16)*2^e - 16 
    ret
  
 
# a0: The value to be encoded
uf8_encode:
    # a1: exponent
    # a2: offset
    la a2, table    # Load offset table
    li a1, 0        # Initial exponent value
    li t1, 15       # Maximum exp value
    lw t2, 0(a2)    # Load data of offset table
next_offset:
    lw t2, 0(a2)    # Load data of offset table
    blt a0, t2, end_uf8_encode    # If value less than next offset

    # Go to next offset value
    addi a1, a1, 1    # Exponent++
    addi a2, a2, 4    # Next offset address
    mv t3, t2         # Store previous data
    bge a1, t1, end_uf8_encode
    j next_offset
    
end_uf8_encode:
    mv a2, t3         # Store offset value into a2
    sub t0, a0, a2    # Mantissa = value(a0)-a2(overflow)
    srl t0, t0, a1    # Mantissa >> exponent(a1)
    slli a1, a1, 4    # Exp(a1) << 4
    or a0, a1,t0      # Store exp << 4 | Mantissa
    ret
    



