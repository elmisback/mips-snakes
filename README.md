#mips-snakes

A MIPS implementation of Snakes! for Dr. Youtao Zhang's CS 447 at the 
University of Pittsburgh.  

## The Algorithm
I used a standard animation algorithm for moving the game's eponymous snake.
In pseudocode, it looks like this:

    t = sys.time()
    while True:
        sleep(SMALL_INTERVAL)
        if key_pressed(): # set new direction here; 
                          # true if the direction has changed, else false
            move_snake()
            t = sys.time()
        elif sys.time() - t > 200ms:
            move_snake()

The move\_snake() function was also fairly simple. Before making a move, it
calls a validation function to check what's in the move destination. If the
destination is empty, the snake's tail segment is deleted and the destination
is added as the new head segment.  If the destination is part of the snake, the
game is over. If the destination is a frog, the snake "consumes" the frog (the
tail is not deleted and the head advances). If the destination is a wall, the
validation function returns a value to indicate that the snake is tentatively 
stuck. The move function responds to a stuck position by trying to turn left or 
right (in a randomized order). If neither turn works, the snake is officially 
stuck and the game ends.

As suggested in the assignment's writeup, I used a circular buffer to implement 
a queue for tracking the snake's position. The snake's head corresponds to the 
back of the queue, where elements are added; its tail corresponds to the front 
of the queue, where elements are dequeued.

## Extra Credit
Note the splash screen's decadent grandeur.
