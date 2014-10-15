# snakes.asm
# @author: Edward L. Misback (elm139)
# A version of Snakes! implemented in MIPS.

.include "stdlib.asm"
#.include "LED.asm"

.eqv BOARD_AREA     4096
.eqv BOARD_LEN      64
.eqv MAX_FROGS      32
.eqv SLEEP_MS       200
.eqv SPLASH_MS      1
.eqv Q_MASK         0x1FFF

.data
# The snake is a circular buffer of 2-byte tuples.
SNAKE: .half 0x0000:BOARD_AREA    
FRONT: .half 0
BACK: .half 0
V_X: .byte 1
V_Y: .byte 0
TIME: .word 0
FROGS_EATEN: .byte 0
FROGS_REMAINING: .byte 0
GAME_WALLS:
    .ascii "****************************************  **********************"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                               **********************         *"
    .ascii "*                                                    *         *"
    .ascii "*                               **********************         *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*       *                                                      *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "*                                                              *"
    .ascii "***************                        *************************"
    .ascii "                                       *                        "
    .ascii "*********                              *  **********************"
    .ascii "*                                      *                       *"
    .ascii "*                                      *                       *"
    .ascii "*                                      *  *                    *"
    .ascii "*                                      *  *                    *"
    .ascii "****************************************  **********************"

SPLASH_WALLS:
    .ascii "****************************************************************"
    .ascii "*        * *   *      *   *   *   *   *   *   *                *"
    .ascii "*  *   *     *  *                                *             *"
    .ascii "* *      *    * *             *   *             *              *"
    .ascii "*       *     *  *           *  *  *       * *                **"
    .ascii "*              * *             * *        *   *                *"
    .ascii "*              *  *          *     *        *                  *"
    .ascii "*       *       * *         *  * *  *   *   *            *     *"
    .ascii "* *      *      *  *          *   *      * *  * *         *    *"
    .ascii "*  *  *          * *        *       *   *     *  *        *    *"
    .ascii "*      *         *  *      *  *   *  *       *  *         *    *"
    .ascii "**                * *        *     *      *              *     *"
    .ascii "*                 *  *     *         *  *  *                   *"
    .ascii "*                  * *    *  *     *  *  *  *                  *"
    .ascii "**                 *  *   * *       * *   *  *                **"
    .ascii "*      *     *      *   *   *       *   *  *    *              *"
    .ascii "*     * *   *        * * * *   * *   * *    *  * *             *"
    .ascii "*                                                              *"
    .ascii "* *****************************   **************************** *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *                           *   *                          * *"
    .ascii "* *****************************   **************************** *"
    .ascii "*                               *                              *"
    .ascii "****************************************************************"
 
.text
j main

_tuple:
    # Builds a 2-byte tuple ($a0, $a1).
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

_split_tuple:
    # Splits the 2-byte tuple in $a0 into two single-byte values.
    # Returns x in $v0 and y in $v1.
    andi $v1, $a0, 0xff
    srl $v0, $a0, 8
    jr $ra

.macro split_tuple (%t)
    add $a0, $zero, %t
    jal _split_tuple
.end_macro


    # void _setLED(int x, int y, int color)
    #   sets the LED at (x,y) to color
    #   color: 0=off, 1=red, 2=yellow, 3=green
    #
    # arguments: $a0 is x, $a1 is y, $a2 is color
    # trashes:   $t0-$t3
    # returns:   none
    #
_setLED:
    # byte offset into display = y * 16 bytes + (x / 4)
    sll    $t0,$a1,4      # y * 16 bytes
    srl    $t1,$a0,2      # x / 4
    add    $t0,$t0,$t1    # byte offset into display
    li    $t2,0xffff0008 # base address of LED display
    add    $t0,$t2,$t0    # address of byte with the LED
    # now, compute led position in the byte and the mask for it
    andi    $t1,$a0,0x3    # remainder is led position in byte
    neg    $t1,$t1        # negate position for subtraction
    addi    $t1,$t1,3      # bit positions in reverse order
    sll    $t1,$t1,1      # led is 2 bits
    # compute two masks: one to clear field, one to set new color
    li    $t2,3        
    sllv    $t2,$t2,$t1
    not    $t2,$t2        # bit mask for clearing current color
    sllv    $t1,$a2,$t1    # bit mask for setting color
    # get current LED value, set the new field, store it back to LED
    lbu    $t3,0($t0)     # read current LED value    
    and    $t3,$t3,$t2    # clear the field for the color
    or    $t3,$t3,$t1    # set color field
    sb    $t3,0($t0)     # update display
    jr    $ra

.macro set_LED (%pos, %color)
    # see _setLED for documentation.
    split_tuple(%pos)
    move $a0, $v0
    move $a1, $v1
    add $a2, $zero, %color
    jal _setLED
.end_macro

    # int _getLED(int x, int y)
    #   returns the value of the LED at position (x,y)
    #
    #  arguments: $a0 holds x, $a1 holds y
    #  trashes:   $t0-$t2
    #  returns:   $v0 holds the value of the LED (0, 1, 2 or 3)
    #
_getLED:
    # byte offset into display = y * 16 bytes + (x / 4)
    sll  $t0,$a1,4      # y * 16 bytes
    srl  $t1,$a0,2      # x / 4
    add  $t0,$t0,$t1    # byte offset into display
    la   $t2,0xffff0008
    add  $t0,$t2,$t0    # address of byte with the LED
    # now, compute bit position in the byte and the mask for it
    andi $t1,$a0,0x3    # remainder is bit position in byte
    neg  $t1,$t1        # negate position for subtraction
    addi $t1,$t1,3      # bit positions in reverse order
        sll  $t1,$t1,1      # led is 2 bits
    # load LED value, get the desired bit in the loaded byte
    lbu  $t2,0($t0)
    srlv $t2,$t2,$t1    # shift LED value to lsb position
    andi $v0,$t2,0x3    # mask off any remaining upper bits
    jr   $ra

.macro get_LED (%pos)
    # see _getLED for documentation.
    split_tuple(%pos)
    move $a0, $v0
    move $a1, $v1
    jal _getLED
.end_macro

_enqueue:
    # Insert an element into the back of a queue.
    # a0: the queue
    # a1: pointer to the half-word back of the queue
    # a2: the half-word element to insert
    lhu $t0, ($a1)
    addi $t0, $t0, 2            # add sizeof(half) to index
    andi $t0, $t0, Q_MASK       # mod index by maximum queue length
    add $t1, $t0, $a0
    sh $a2, ($t1)               # store the element at tail
    sh $t0, ($a1)               # store new queue tail
    jr $ra

.macro enqueue (%e)
    # %e is the element to be enqueued
    la $a0, SNAKE
    la $a1, BACK
    add $a2, $zero, %e
    jal _enqueue 
.end_macro

_dequeue:
    # Dequeue an element from a queue's front and return it in $v0.
    # a0: the queue
    # a1: pointer to the half-word front index 
    lhu $t0, ($a1)
    addi $t0, $t0, 2        # add sizeof(half) to index
    andi $t0, $t0, 0x1FFF   # mod index by maximum queue length - 1
    sh $t0, ($a1)           # set new queue head
    add $t1, $t0, $a0
    lhu $v0, ($t1)          # load element
    jr $ra

.macro dequeue ()
    la $a0, SNAKE
    la $a1, FRONT
    lh $t0, FRONT
    lh $t1, BACK
    bne $t0, $t1, CONTINUE
    break                   # can't deque from empty queue
    CONTINUE:
    jal _dequeue
.end_macro

_back_peek:
    # Peek at the last element of a queue and return it in $v0.
    # a0: the queue
    # a1: pointer to the half-word back index for the queue
    lhu $t0, ($a1)
    add $t1, $t0, $a0
    lhu $v0, ($t1)          # load element
    jr $ra

.macro back_peek
    la $a0, SNAKE
    la $a1, BACK
    jal _back_peek
.end_macro

_empty_queue:
    # "Empties" the queue by setting front = back = index 0.
    # a0: pointer to front
    # a1: pointer to back 
    sh $zero, ($a0)
    sh $zero, ($a1)
    jr $ra

.macro empty_queue ()
    la $a0, FRONT
    la $a1, BACK
    jal _empty_queue
.end_macro

_init_snake:
    # Initializes the snake (snake points right).
    # a0: starting row
    # a1: starting col
    # a2: starting length
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s1, $a0
    move $s2, $a1
    add $s3, $s2, $a2

    empty_queue()           # Clear any data leftover from the splash. 

    .macro ADD_TUP
        tuple($s0, $s1)
        move $s1, $v0
        enqueue($s1)
        set_LED($s1, 2)
    .end_macro
    
    for ($s0, $s2, $s3, ADD_TUP)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

.macro init_snake (%row, %col, %len)
    add $a0, $zero, %row
    add $a1, $zero, %col
    add $a2, $zero, %len
    jal _init_snake
.end_macro

_init_walls:
    # Initializes the board's walls.
    # a0: a pointer to the wall configuration
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s1, $a0
    .macro BUILD_PANEL
        add $t1, $s0, $s1
        lbu $t0, ($t1)
        beq $t0, ' ', SKIP
        andi $t0, $s0, 0x3f
        div $t1, $s0, BOARD_LEN
        tuple($t0, $t1)
        set_LED($v0, 1)
        SKIP:
    .end_macro
    for($s0, 0, BOARD_AREA, BUILD_PANEL)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

_init_frogs:
    # Initializes the board's frogs.
    # Makes one frog with total certainty; adds up to MAX_FROGS.
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    .macro PLACE_FROG
        randint(64)                     # Generate a position.
        move $t0, $v0
        randint(64)

        move $t1, $v0
        tuple($t0, $t1) 
        move $s0, $v0
        get_LED($s0)                    # Check the position.
        bnez $v0, SKIP
        set_LED($s0, 3) 
        move $v0, $zero                 # Note a place was found.
        lb $t0, FROGS_REMAINING         # Update global frog number.
        add $t0, $t0, 1
        sb $t0, FROGS_REMAINING
        SKIP:
    .end_macro
    FROG_WHILE:
        PLACE_FROG     
        beq $v0, $zero, END_FROG_WHILE  # Termination condition.
    j FROG_WHILE
    END_FROG_WHILE:
    add $s2, $zero, MAX_FROGS
    addi $s2, $s2, -1
    for($s1, 0, $s2, PLACE_FROG)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

_clear_row:
    # Turns off all cells in the specified row.
    # a0: the row number
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0

    .macro TURN_OFF_CELL
        tuple($s1, $s0)
        set_LED($v0, 0)
    .end_macro

    for($s1, 0, BOARD_LEN, TURN_OFF_CELL)      
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

_clear_board:
    # Turns off all cells in the board.
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    .macro TURN_OFF_ROW
        move $a0, $s0
        jal _clear_row
    .end_macro
    for($s0, 0, BOARD_LEN, TURN_OFF_ROW)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

.macro init_game ()
    jal _clear_board
    init_snake (31, 4, 8)
    la $a0, GAME_WALLS
    jal _init_walls
    jal _init_frogs
.end_macro

_game_over:
    lw $t0, TIME
    PRINT_STR("Game over.\n")
    PRINT_STR("The playing time was ")
    PRINT_REG($t0, 'd')
    PRINT_STR(" ms.\n")
    PRINT_STR("The game score was ")
    lb $t0, FROGS_EATEN
    PRINT_REG($t0, 'd')
    PRINT_STR(" frogs.\n")

    done()

.macro game_over ()
    jal _game_over
.end_macro

_attempt_move:
    # Moves the snake in the direction specified by V_X and V_Y.
    # a0: stuck status (1 for stuck, 0 otherwise)
    # $v0 = 0 upon success, 1 upon failure.
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $s0, $a0
    back_peek() 
    split_tuple($v0)
    lb $t0, V_X
    lb $t1, V_Y
    add $t2, $v0, $t0       # calculate the new position
    andi $t2, $t2, 0x3f
    add $t3, $v1, $t1       # (wraparound)
    andi $t3, $t3, 0x3f
    tuple($t2, $t3)
    move $s1, $v0 
    get_LED($s1) 
    beq $v0, 0, EMPTY
    beq $v0, 1, HIT_WALL
    beq $v0, 2, HIT_SNAKE
    beq $v0, 3, HIT_FROG
    EMPTY:
        # Move the snake forward.
        enqueue($s1) 
        set_LED($s1, 2)
        dequeue()
        set_LED($v0, 0)
        addi $v0, $zero, 0
        j ATTEMPT_MOVE_EPILOGUE
    HIT_WALL:
        # Report failure.
        addi $v0, $zero, 1
        j ATTEMPT_MOVE_EPILOGUE
    HIT_SNAKE:
        beq $s0, $zero, GAME_OVER_0
        # Otherwise report failure.
        addi $v0, $zero, 1 
        j ATTEMPT_MOVE_EPILOGUE
        GAME_OVER_0:
        game_over()
    HIT_FROG:
        # Grow the snake.
        enqueue($s1) 
        set_LED($s1, 2)
        # Record the frog as eaten.
        lb $t0, FROGS_EATEN
        addi $t0, $t0, 1
        sb $t0, FROGS_EATEN
        lb $t0, FROGS_REMAINING
        addi $t0, $t0, -1
        sb $t0, FROGS_REMAINING
        beq $t0, $zero, GAME_OVER_0
        addi $v0, $zero, 0
        j ATTEMPT_MOVE_EPILOGUE
    ATTEMPT_MOVE_EPILOGUE:

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

.macro attempt_move (%stuck)
    add $a0, $zero, %stuck
    jal _attempt_move
.end_macro

_move_snake:
    # Move the snake forward, handling any collisions.
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    move $a0, $zero
    attempt_move(0)
    beq $v0, $zero, FINISH_MOVE
    # Otherwise, we need to try 90 degree turns.
    randint(2)
    move $s0, $v0
    lb $t0, V_X

    beq $t0, $zero, R_L_MOVE
        # up/down moves
        lb $s1, V_X             # keep track of old direction
        mul $t2, $s0, -2        # v_y = 1 + -2 * s0
        addi $t0, $t2, 1        # v_x = 0
        sb $t0, V_Y
        sb $zero, V_X
        attempt_move(1)
        beq $v0, $zero, FINISH_MOVE
        mul $t2, $s0, 2         # v_y = -1 + 2 * s0
        addi $t0, $t2, -1
        sb $t0, V_Y
        attempt_move(1)
        beq $v0, $zero, FINISH_MOVE
        neg $t0, $s1            # finally, check "backwards"
        sb $zero, V_Y
        sb $t0, V_X
        attempt_move(1)
        j FINISH_MOVE
    R_L_MOVE:
        # right/left moves
        lb $s1, V_Y             # keep track of old direction
        mul $t2, $s0, -2        # v_x = 1 + -2 * s0
        addi $t0, $t2, 1        # v_y = 0
        sb $t0, V_X
        sb $zero, V_Y
        attempt_move(1)
        beq $v0, $zero, FINISH_MOVE
        mul $t2, $s0, 2         # v_x = -1 + 2 * s0
        addi $t0, $t2, -1
        sb $t0, V_X
        attempt_move(1)
        beq $v0, $zero, FINISH_MOVE
        neg $t0, $s1            # finally, check "backwards"
        sb $zero, V_X
        sb $t0, V_Y
        attempt_move(1)
    FINISH_MOVE:
        bgtz $v0, GAME_OVER_1

        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        addi $sp, $sp, 12
        jr $ra
    GAME_OVER_1:
        game_over()

.macro move_snake ()
    jal _move_snake
.end_macro

_handle_key_press:
    # Handle user key presses; discard illegal presses (i.e. backwards presses)

    # Get the pressed key.
    move $t2, $zero
    la $t0, 0xffff0000
    lbu $t1, ($t0)
    beq $t1, $zero, FINISH_KEY_PRESSED
    lbu $t2, 4($t0)
    FINISH_KEY_PRESSED:
    beq $t2, 0xe0, DIR_UP
    beq $t2, 0xe2, DIR_LEFT 
    beq $t2, 0xe1, DIR_DOWN 
    beq $t2, 0xe3, DIR_RIGHT 
    beq $t2, 0x42, BUTTON 
    lb $t0, V_X
    lb $t1, V_Y
    j FINISH_HANDLE_KEY_PRESS
    DIR_DOWN:
        addi $t0, $zero, 0
        addi $t1, $zero, 1
        j FINISH_HANDLE_KEY_PRESS 
    DIR_LEFT:
        addi $t0, $zero, -1
        addi $t1, $zero, 0
        j FINISH_HANDLE_KEY_PRESS 
    DIR_UP:
        addi $t0, $zero, 0
        addi $t1, $zero, -1
        j FINISH_HANDLE_KEY_PRESS 
    DIR_RIGHT:
        addi $t0, $zero, 1
        addi $t1, $zero, 0
        j FINISH_HANDLE_KEY_PRESS 
    BUTTON:
        j FINISH_HANDLE_KEY_PRESS
    FINISH_HANDLE_KEY_PRESS:
    # Finally, test for illegal presses.
    lb $t2, V_X
    lb $t3, V_Y
    neg $t2, $t2
    neg $t3, $t3
    bne $t0, $t2, UPDATE_V
    bne $t1, $t3, UPDATE_V
        jr $ra
    UPDATE_V:
        sb $t0, V_X
        sb $t1, V_Y
        jr $ra

.macro handle_key_press ()
    jal _handle_key_press
.end_macro

.macro sleep (%ms)
    add $a0, $zero, %ms
    la $v0, 32
    syscall
.end_macro

_handle_splash_press:
    # Check if any key was pressed.
    la $t0, 0xffff0000
    lbu $v0, ($t0)
    jr $ra

_display_splash:
    # Shows an animated splash screen for the game.
    addi $sp, $sp, -4
    sw $ra, ($sp)

    jal _clear_board
    la $a0, SPLASH_WALLS
    jal _init_walls
    init_snake (17, 1, 62)
    SPLASH_BODY:
        sleep(SPLASH_MS)
        jal _handle_splash_press
        bgtz $v0, END_SPLASH
        move_snake()
    j SPLASH_BODY

    END_SPLASH:
    lw $ra, ($sp)
    addi $sp, $sp, 4
    jr $ra

main:
    jal _display_splash
    init_game()
    move $s0, $zero
    BODY:
        sleep(SLEEP_MS)
        add $s0, $s0, SLEEP_MS
        sw $s0, TIME
        handle_key_press()
        move_snake()
    j BODY
