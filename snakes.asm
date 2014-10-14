# snakes.asm
# @author: Edward L. Misback (elm139)
# A version of Snakes! implemented in MIPS.

.data
SNAKE: .half 0x0000:4096    # The snake is an array of 2-byte tuples.
HEAD: .half 0
TAIL: .half 0
X_V: .byte -1
Y_V: .byte 0

.eqv Q_MASK         0x1FFF
.eqv SIZEOF_HALF    2



# for loop. Range: [from, to)
.macro FOR (%regIterator, %from, %to, %bodyMacroName)
    add %regIterator, $zero, %from
    FOR_LOOP:
    %bodyMacroName ()
    add %regIterator, %regIterator, 1
    blt %regIterator, %to, FOR_LOOP
.end_macro

# No side effects.
.macro PRINT_STR (%str)
    .data
    PRINT_STR_S_0: .asciiz %str
    .text
    addiu $sp, $sp, -8
    sw $v0, ($sp)
    sw $a0, 4($sp)
    li $v0, 4
    la $a0, PRINT_STR_S_0
    syscall
    lw $v0, ($sp)
    lw $a0, 4($sp)
    addiu $sp, $sp, 8
.end_macro


# No side effects.
# %type is a single char.
.macro PRINT_REG (%reg, %type)
    .data
    PRINT_REG_C_0: .byte %type
    .text
    addiu $sp, $sp, -12
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
    addiu $sp, $sp, 12
.end_macro

.text
j main

_tuple:
    # Builds a 2-byte tuple.
    # a0: x (1 byte)
    # a1: y (1 byte)
    andi $a0, $a0, 0xff
    andi $a1, $a1, 0xff
    add $v0, $zero, $a0 
    sll $v0, $v0, 8 
    add $v0, $v0, $a1
    jr $ra

.macro tuple (%x, %y)
    add $a0, $zero, %x
    add $a1, $zero, %y
    jal _tuple
.end_macro


_enqueue:
    # Insert an element into a queue.
    # a0: the queue
    # a1: pointer to the half-word head index for the queue
    # a2: the half-word element to insert
    lhu $t0, ($a1)
    addi $t0, $t0, 2            # add sizeof(half) to index
    andi $t0, $t0, Q_MASK       # mod index by maximum queue length
    add $t1, $t0, $a0
    sh $a2, ($t1)               # store the element at head
    sh $t0, ($a1)               # store new queue head
    jr $ra

.macro enqueue (%e)
    # %e is the element to be enqueued
    la $a0, SNAKE
    la $a1, HEAD
    add $a2, $zero, %e
    jal _enqueue
    
.end_macro

_dequeue:
    # Dequeue an element and return it in $v0.
    # a0: the queue
    # a1: pointer to the half-word tail index 
    lhu $t0, ($a1)
    addi $t0, $t0, 2        # add sizeof(half) to index
    andi $t0, $t0, 0x1FFF   # mod index by maximum queue length - 1
    sh $t0, ($a1)           # set new queue tail 
    add $t1, $t0, $a0
    lhu $v0, ($t1)          # load element
    jr $ra

.macro dequeue
    la $a0, SNAKE
    la $a1, TAIL
    lh $t0, HEAD
    lh $t1, TAIL
    bne $t0, $t1, CONTINUE
    break                   # can't deque from empty queue
    CONTINUE:
    jal _dequeue
.end_macro

_tail_peek:
    # Peek at the tail element and return it in $v0.
    # a0: the queue
    # a1: pointer to the half-word tail index for the queue
    lhu $t0, ($a1)
    addi $t0, $t0, 2        # add sizeof(half) to index
    andi $t0, $t0, 0x1FFF   # mod index by maximum queue length - 1
    add $t1, $t0, $a0
    lhu $v0, ($t1)          # load element
    jr $ra



.macro tail_peek
    la $a0, SNAKE
    la $a1, TAIL
    jal _tail_peek
.end_macro

_init_snake:
    # Initializes the game board.
    .macro ADD_TUP
        tuple($s0, 31)
        enqueue($v0)
    .end_macro
    FOR ($s0, 4, 11, ADD_TUP)
    jr $ra

.macro init_game ()
    # TODO: add frog initialization.
    jal _init_snake
.end_macro

main:
    init_game()
    dequeue
    PRINT_REG($v0, 'x')
