.file "src/game/playing.s"

handle_playing:
    call check_collision
    cmp $1, %rax
    je collision_detected                    # if collision detected go to game over

    # increase obstacle speed gradually (acceleration)
    mov obst_speed_init_fp(%rip), %rax
    add obst_accel_fp(%rip), %rax
    mov %rax, obst_speed_init_fp(%rip)

    # erase old dino position
    mov dino_x(%rip), %rdi
    mov dino_y(%rip), %rsi
    sar $16, %rsi
    mov $24, %rdx
    mov $24, %rcx
    mov $0, %r8
    call drawRect

    # loop to erase all existing obstacles
    mov $MAX_OBSTACLES, %r12
    lea obstacles(%rip), %r13

erase_obstacle_loop:
    mov 16(%r13), %rax
    cmp $0, %rax
    je skip_erase_obstacle                   # skip inactive obstacles

    mov 0(%r13), %rax
    sar $16, %rax
    mov %rax, %rdi
    mov $130, %rsi
    mov $20, %rdx
    mov $20, %rcx
    mov $0, %r8
    call drawRect                            # clear previous obstacle 

skip_erase_obstacle:
    add $32, %r13
    dec %r12
    jnz erase_obstacle_loop
    #--------------------------------------


    # update obstacle positions
    mov $MAX_OBSTACLES, %r12
    lea obstacles(%rip), %r13

update_loop:
    mov 16(%r13), %rax
    cmp $0, %rax
    je nothing_to_update                     # skip inactive

    mov obst_speed_init_fp(%rip), %rax
    mov %rax, 8(%r13)                        # update speed

    mov (%r13), %rax
    sub 8(%r13), %rax                        # move obstacle left based on computed velocity
    mov %rax, (%r13)
    
    sar $16, %rax
    cmp $0, %rax
    jg nothing_to_update                     # if still visible, skip

    mov $0, 16(%r13)                         # deactivate obstacle if it has reached the end of screen
    mov $0, (%r13)

nothing_to_update:
    add $32, %r13
    dec %r12
    jnz update_loop


# obstacle spawning logic

    mov spawn_timer(%rip), %rax
    inc %rax
    mov %rax, spawn_timer(%rip)
    mov spawn_interval(%rip), %r14
    cmp %rax, %r14
    jg no_spawn                              # not yet time to spawn
    cmp %rax, %r14
    jne check_to_spawn

random_time:
    mov $0, %rdi
    mov $100, %rsi
    call randInRange                         # generate random delay when we hit the desired range(spawn interval)
    mov spawn_interval(%rip), %rdx
    add %rdx, %rax
    mov %rax, timer_for_random(%rip)

check_to_spawn:
    mov spawn_timer(%rip), %rax              #keep updating the time, if we hit the random time generated, then we can spawn an obstacle
    mov timer_for_random(%rip), %r14
    cmp %rax, %r14
    jne no_spawn


# find empty obstacle slot and spawn new one

slot_fill:
    mov $MAX_OBSTACLES, %r12
    lea obstacles(%rip), %r13

first_active_slot_gets_filled:
    mov 16(%r13), %rax
    cmp $1, %rax
    jne put_and_go                          #iterate through slots, first empty slot gets filled
    add $32, %r13
    jmp first_active_slot_gets_filled

put_and_go:
    movq $1, 16(%r13)                        # mark slot active
    mov obst_spawn_x_fp(%rip), %rax
    mov %rax, 0(%r13)                        # set spawn x position
    mov obst_speed_init_fp(%rip), %rax
    mov %rax, 8(%r13)                        # set speed
    
    push %r13
    mov $0, %rdi
    mov $2, %rsi
    call randInRange                         # random type (0–2)
    pop %r13
    mov %rax, 24(%r13)

done_finding_slot:
    mov spawn_interval(%rip), %rax          #decrement spawn interval so we generate obstacles more rapidly
    cmp $30, %rax
    je cap
    dec %rax
    mov %rax, spawn_interval(%rip)
    mov $0, %rax
    mov %rax, spawn_timer(%rip)             #reset spawn timer(current timer)
    jmp no_spawn

cap:
    mov $30, %rax
    mov %rax, spawn_interval(%rip)           #cap spawn interval at 30 so we dont spawn obstacles very very fast
    mov $0, %rax
    mov %rax, spawn_timer(%rip)


# draw ground line

no_spawn:
    mov $0, %rdi
    mov ground_y(%rip), %rsi
    mov $319, %rdx
    mov ground_y(%rip), %rcx
    mov $2, %r8
    call putLine


# draw all obstacles

    mov $MAX_OBSTACLES, %r12
    lea obstacles(%rip), %r13 

draw_obstacle_loop:
    mov 16(%r13), %rax                  #check if active
    cmp $0, %rax
    je dont_draw

    mov (%r13), %r15
    sar $16, %r15
    cmp $0, %r15
    jl dont_draw                             # if outside screen, skip

    mov 24(%r13), %rax                       # load obstacle type
    cmp $0, %rax
    je obst_0
    cmp $1, %rax
    je obst_1
    cmp $2, %rax
    je obst_2

obst_0:
    lea CACTUS_TALL(%rip), %rdi
    mov %r15, %rsi
    mov $135, %rdx
    call putBitmap
    jmp dont_draw

obst_1:
    lea CACTUS_SMALL(%rip), %rdi
    mov %r15, %rsi
    mov $140, %rdx
    call putBitmap
    jmp dont_draw

obst_2:
    lea BIRD(%rip), %rdi
    mov %r15, %rsi
    mov $130, %rdx
    call putBitmap
    jmp dont_draw
    
dont_draw:
    add $32, %r13
    dec %r12
    cmp $0, %r12
    jnz draw_obstacle_loop

# update dino position (jump physics)

    mov velocity_y(%rip), %rax
    add gravity(%rip), %rax
    mov %rax, velocity_y(%rip)

    mov dino_y(%rip), %rbx
    add velocity_y(%rip), %rbx
    mov %rbx, dino_y(%rip)

    mov ground_y(%rip), %rdx
    sub $10, %rdx
    mov dino_y(%rip), %rcx
    sar $16, %rcx
    cmp %rdx, %rcx
    jle check_input                          # if above ground, skip reset

    mov $140, %rax
    sal $16, %rax
    mov %rax, dino_y(%rip)                   # reset position to ground
    mov $0, %rax
    mov %rax, velocity_y(%rip)


# handle player input (jump, duck, quit)

check_input:
    mov dino_y(%rip), %rax
    sar $16, %rax
    cmp $140, %rax
    je continue_input                       #listen to input while only on the ground

flush_midair:
    call ps2_getkey
    cmp $0, %r8
    jne flush_midair                         # flush key buffer while midair

continue_input:
    call ps2_getkey
    cmp $0, %r8
    je after_input_check                     # if no key pressed 
    call ps2_translate_scancode

    cmp $49, %r8                             # key '1' - back to menu
    jne here
    mov $0, menu_init(%rip)
    mov $0, game_state(%rip)

here:
    cmp $115, %r8                            # key 's' - duck toggle
    jne check_space
    mov is_ducking(%rip), %rax
    xor $1, %rax                             # switch the ducking state 
    mov %rax, is_ducking(%rip)
    
check_space:
    cmp $32, %r8                             # space - jump
    jne after_input_check
    mov dino_y(%rip), %rax
    sar $16, %rax
    cmp $140, %rax
    jne after_input_check                   # only jump if on ground
    movq $0, is_ducking(%rip)                #if ducled while jumping switch back to unducked
    mov $-450000, %rax                       # jump velocity
    mov %rax, velocity_y(%rip)
    add %rax, dino_y(%rip)

flush_buffer:
    call ps2_getkey
    cmp $0, %r8
    jne flush_buffer                         # clear buffer after jump


# draw dino (normal or ducking)

after_input_check:
    mov is_ducking(%rip), %rax
    cmp $1, %rax
    je draw_ducked                          #draw main figure based on ducking state

    lea DINO(%rip), %rdi
    mov dino_x(%rip), %rsi
    mov dino_y(%rip), %rdx
    sar $16, %rdx
    call putBitmap
    jmp end_draw_dino

draw_ducked:
    lea DINO_DUCK(%rip), %rdi
    mov dino_x(%rip), %rsi
    mov dino_y(%rip), %rdx
    sar $16, %rdx
    add $4, %rdx                             # adjust for lower position
    call putBitmap


# draw score (top right)

end_draw_dino:
    mov current_score(%rip), %rax
    add $1, %rax
    mov %rax, current_score(%rip)            # increment score
    mov $305, %rax
    mov %rax, location_score(%rip)
    mov $5, digits_y(%rip)
    call display_score 
    ret

# handle collision detected (end game)

collision_detected:
    movq $STATE_GAME_OVER, game_state(%rip)
    ret

