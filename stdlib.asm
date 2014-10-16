# A standard library for the MIPS-Snakes project.
j _END_OF_STDLIB

.macro done
    li $v0, 10
    syscall
.end_macro    

_time:
    # Returns the system time in registers $v0 and $v1.
    # $v0 = lo, $v1 = hi 32 bits.
    addi $sp, $sp, -8
    sw $a0, ($sp)
    sw $a1, 4($sp)

    la $v0, 30
    syscall
    move $v0, $a0
    move $v1, $a1

    lw $a0, ($sp)
    lw $a1, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# No side effects, besides return values.
.macro time ()
    addi $sp, $sp, -4
    sw $ra, ($sp)

    jal _time 

    lw $ra, ($sp)
    addi $sp, $sp, 4
.end_macro

_randint:
    # Returns a random integer in a range in $v0.
    # a1: the upper bound for the range
    # Preserves all other registers.
    addi $sp, $sp, -4
    sw $a0, ($sp)

    la $v0, 42
    syscall
    move $v0, $a0

    lw $a0, ($sp)
    addi $sp, $sp, 4
    jr $ra

# Range: [0, u)
# No side effects, besides return value (in $v0).
.macro randint (%u)
    addi $sp, $sp, -8
    sw $ra, ($sp)
    sw $a1, 4($sp)

    add $a1, $zero, %u
    jal _randint

    lw $ra, ($sp)
    lw $a1, 4($sp)
    addi $sp, $sp, 8
.end_macro

# for loop. Range: [from, to)
.macro for (%regIterator, %from, %to, %bodyMacroName)
    add %regIterator, $zero, %from
    for_LOOP:
    %bodyMacroName ()
    add %regIterator, %regIterator, 1
    blt %regIterator, %to, for_LOOP
.end_macro

# No side effects.
.macro PRINT_STR (%str)
    .data
    PRINT_STR_S_0: .asciiz %str
    .text
    addi $sp, $sp, -8
    sw $v0, ($sp)
    sw $a0, 4($sp)
    li $v0, 4
    la $a0, PRINT_STR_S_0
    syscall
    lw $v0, ($sp)
    lw $a0, 4($sp)
    addi $sp, $sp, 8
.end_macro

# No side effects.
# %type is a single char.
.macro PRINT_REG (%reg, %type)
    .data
    PRINT_REG_C_0: .byte %type
    .text
    addi $sp, $sp, -12
    sw $a0, 0($sp)
    sw $v0, 4($sp)
    sw $t0, 8($sp)
    move $a0, %reg
    lbu $t0, PRINT_REG_C_0
    beq $t0, 's', PRINT_TYPE_STR
    beq $t0, 'd', PRINT_TYPE_INT
    beq $t0, 'x', PRINT_TYPE_HEX
    beq $t0, 'f', PRINT_TYPE_FLOAT
    beq $t0, '2', PRINT_TYPE_DOUBLE
    beq $t0, 'c', PRINT_TYPE_CHAR
    beq $t0, 'b', PRINT_TYPE_BIN
    PRINT_STR ("Couldn't find string type.")
    break
    PRINT_TYPE_STR:
    li $v0, 4
    j FINISH_PRINT
    PRINT_TYPE_INT:
    li $v0, 1
    j FINISH_PRINT
    PRINT_TYPE_HEX:
    li $v0, 34
    j FINISH_PRINT
    PRINT_TYPE_FLOAT:
    li $v0, 2
    j FINISH_PRINT
    PRINT_TYPE_DOUBLE:
    li $v0, 3
    j FINISH_PRINT
    PRINT_TYPE_CHAR:
    li $v0, 11
    j FINISH_PRINT
    PRINT_TYPE_BIN:
    li $v0, 35
    j FINISH_PRINT
    FINISH_PRINT:
    syscall
    lw $a0, 0($sp)
    lw $v0, 4($sp)
    lw $t0, 8($sp)
    addi $sp, $sp, 12
.end_macro


_END_OF_STDLIB:
