.file "src/game/methods.s"

check_high_score:                                       #check highscore method returns the rank of the player(1 2 or 3 ( 0 1 or 2 ))
    push %rbp
    mov %rsp, %rbp
    
    mov current_score(%rip), %rax
    lea leaderboard_data(%rip), %r10                    #load address of leaderboard data table and process the current score
    
    mov 8(%r10), %r11                                   #load the existing scores from the table and compare with each of them to see if we have readched top 3 and which rank if so
    cmp %r11, %rax
    jg rank_0
    
    mov 24(%r10), %r11
    cmp %r11, %rax
    jg rank_1
    
    mov 40(%r10), %r11
    cmp %r11, %rax
    jg rank_2
    
    mov $-1, %rax                                    #if we haven t reached a highscore we return -1
    jmp check_done
    
rank_0:
    mov $0, %rax
    jmp check_done
    
rank_1:
    mov $1, %rax
    jmp check_done
    
rank_2:
    mov $2, %rax
    
check_done:
    leave
    ret

#====================================================

insert_into_leaderboard:
    push %rbp
    mov %rsp, %rbp
    
    mov high_score_rank(%rip), %rax
    cmp $-1, %rax
    je insert_done                          # no new high score so skip
    
    cmp $0, %rax
    je insert_rank_0                        #depending on rank modify the leaderboard
    cmp $1, %rax
    je insert_rank_1
    jmp insert_rank_2


insert_rank_0:       #insert in rank 0 means shifting old rank 0 and rank 1 to rank 1 and rank 2 respectively
    lea leaderboard_data(%rip), %r10

    # move old rank1 to  rank2
    mov 16(%r10), %rax                     # name1
    mov %rax, 32(%r10)
    mov 24(%r10), %rax                     # score1
    mov %rax, 40(%r10)

    # move old rank0 to rank1
    mov 0(%r10), %rax                      # name0
    mov %rax, 16(%r10)
    mov 8(%r10), %rax                      # score0
    mov %rax, 24(%r10)

    # insert new player at rank0
    lea player_name(%rip), %r11
    mov (%r11), %rax
    mov %rax, 0(%r10)
    mov current_score(%rip), %rax
    mov %rax, 8(%r10)
    jmp insert_done


insert_rank_1:
    lea leaderboard_data(%rip), %r10

    # move old rank1 to rank2
    mov 16(%r10), %rax
    mov %rax, 32(%r10)
    mov 24(%r10), %rax
    mov %rax, 40(%r10)

    # insert new player at rank1
    lea player_name(%rip), %r11
    mov (%r11), %rax
    mov %rax, 16(%r10)
    mov current_score(%rip), %rax
    mov %rax, 24(%r10)
    jmp insert_done


# insert at rank 2 (new top 3 score)
# simply overwrite rank2

insert_rank_2:
    lea leaderboard_data(%rip), %r10

    lea player_name(%rip), %r11
    mov (%r11), %rax
    mov %rax, 32(%r10)
    mov current_score(%rip), %rax
    mov %rax, 40(%r10)

insert_done:
    leave
    ret


#=============================================
#score drawing method, prints one score at a time in a specific place
#used both leaderboard section and game over handling

display_score:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    
    mov location_score(%rip), %r12          #x position of where to print a specific score
    mov current_score(%rip), %rax          
    
score_loop:
    cmp $0, %rax                            #if we drew all digitts jump to score done
    je score_done
    
    xor %rdx, %rdx                          #clear rdx for next diviwion
    mov $10, %rbx                           #divide by 10
    div %rbx
    
    push %rax                               #save the score on the stack before calling putBitmap
    
    cmp $0, %rdx                            #check whihch digit to draw
    je draw_digit_0
    cmp $1, %rdx
    je draw_digit_1
    cmp $2, %rdx
    je draw_digit_2
    cmp $3, %rdx
    je draw_digit_3
    cmp $4, %rdx
    je draw_digit_4
    cmp $5, %rdx
    je draw_digit_5
    cmp $6, %rdx
    je draw_digit_6
    cmp $7, %rdx
    je draw_digit_7
    cmp $8, %rdx
    je draw_digit_8
    jmp draw_digit_9
    
draw_digit_0:
    lea DIGIT0(%rip), %rdi                  #load the bitmap in rdi
    jmp do_draw_digit
draw_digit_1:
    lea DIGIT1(%rip), %rdi
    jmp do_draw_digit
draw_digit_2:
    lea DIGIT2(%rip), %rdi
    jmp do_draw_digit
draw_digit_3:
    lea DIGIT3(%rip), %rdi
    jmp do_draw_digit
draw_digit_4:
    lea DIGIT4(%rip), %rdi
    jmp do_draw_digit
draw_digit_5:
    lea DIGIT5(%rip), %rdi
    jmp do_draw_digit
draw_digit_6:
    lea DIGIT6(%rip), %rdi
    jmp do_draw_digit
draw_digit_7:
    lea DIGIT7(%rip), %rdi
    jmp do_draw_digit
draw_digit_8:
    lea DIGIT8(%rip), %rdi
    jmp do_draw_digit
draw_digit_9:
    lea DIGIT9(%rip), %rdi
    
do_draw_digit:
    mov %r12, %rsi                          #x position to draw digit
    mov digits_y(%rip), %rdx                #y position to drwa digit
    call putBitmap
    
    sub $10, %r12                           #x position gets updated
    
    pop %rax                                #restore the score
    jmp score_loop
    
score_done:
    pop %r13                                #finished printing score and leave
    pop %r12
    pop %rbx
    leave
    ret

#====================================

putNames:
    push %rbp
    mov %rsp, %rbp
    push %r12                
    push %r13
    
    lea leaderboard_data(%rip), %r12         #reference to the leaderboard data table
    movq $3, %r13                            #how many names to print
    movq $90, y_name(%rip)                   #starting y position for the n1 name

draw_next_name:
    movq $79, x_start_name(%rip)             #starting x for the firs character of all names
    movq $8, name_char_counter(%rip)         #keep a limit of 8 characters for a name

loop_write_name:
    movzbq (%r12), %rax                      #process name letter by letter
    
    cmp $65, %rax                            #filter into cases
    je drawA
    cmp $66, %rax
    je drawB
    cmp $67, %rax
    je drawC
    cmp $68, %rax
    je drawD
    cmp $69, %rax
    je drawE
    cmp $70, %rax
    je drawF
    cmp $71, %rax
    je drawG
    cmp $72, %rax
    je drawH
    cmp $73, %rax
    je drawI
    cmp $74, %rax
    je drawJ
    cmp $75, %rax
    je drawK
    cmp $76, %rax
    je drawL
    cmp $77, %rax
    je drawM
    cmp $78, %rax
    je drawN
    cmp $79, %rax
    je drawO
    cmp $80, %rax
    je drawP
    cmp $81, %rax
    je drawQ
    cmp $82, %rax
    je drawR
    cmp $83, %rax
    je drawS
    cmp $84, %rax
    je drawT
    cmp $85, %rax
    je drawU
    cmp $86, %rax
    je drawV
    cmp $87, %rax
    je drawW
    cmp $88, %rax
    je drawX
    cmp $89, %rax
    je drawY
    cmp $90, %rax
    je drawZ
    jmp skip_char

drawA:
    lea A(%rip), %rdi                   #load bitmaps for each specific case
    jmp draw_char
drawB:
    lea B(%rip), %rdi
    jmp draw_char
drawC:
    lea C(%rip), %rdi
    jmp draw_char
drawD:
    lea D(%rip), %rdi
    jmp draw_char
drawE:
    lea E(%rip), %rdi
    jmp draw_char
drawF:
    lea F(%rip), %rdi
    jmp draw_char
drawG:
    lea G(%rip), %rdi
    jmp draw_char
drawH:
    lea H(%rip), %rdi
    jmp draw_char
drawI:
    lea I(%rip), %rdi
    jmp draw_char
drawJ:
    lea J(%rip), %rdi
    jmp draw_char
drawK:
    lea K(%rip), %rdi
    jmp draw_char
drawL:
    lea L(%rip), %rdi
    jmp draw_char
drawM:
    lea M(%rip), %rdi
    jmp draw_char
drawN:
    lea N(%rip), %rdi
    jmp draw_char
drawO:
    lea O(%rip), %rdi
    jmp draw_char
drawP:
    lea P(%rip), %rdi
    jmp draw_char
drawQ:
    lea Q(%rip), %rdi
    jmp draw_char
drawR:
    lea R(%rip), %rdi
    jmp draw_char
drawS:
    lea S(%rip), %rdi
    jmp draw_char
drawT:
    lea T(%rip), %rdi
    jmp draw_char
drawU:
    lea U(%rip), %rdi
    jmp draw_char
drawV:
    lea V(%rip), %rdi
    jmp draw_char
drawW:
    lea W(%rip), %rdi
    jmp draw_char
drawX:
    lea X(%rip), %rdi
    jmp draw_char
drawY:
    lea Y(%rip), %rdi
    jmp draw_char
drawZ:
    lea Z(%rip), %rdi

draw_char:
    mov x_start_name(%rip), %rsi                    #draw a characyer
    mov y_name(%rip), %rdx
    push %r12
    push %r13
    call putBitmap
    pop %r13
    pop %r12
    
    mov x_start_name(%rip), %rax                    #prepare next position to draw for next charcater
    add $10, %rax
    mov %rax, x_start_name(%rip)

skip_char:
    inc %r12                                        #go to the next character
    mov name_char_counter(%rip), %rax
    dec %rax                                        #decrement the number of available characters to print
    mov %rax, name_char_counter(%rip)
    cmp $0, %rax
    jg loop_write_name                              #if we haven t reached the limit yet continue
    
    add $8, %r12                                    #limit is reached, so we go to the next name to print by adding 8(because the leaderbopard table has a score slot for each player, meaning we need to skip that)
    mov y_name(%rip), %rax
    add $15, %rax                                   #current name is done printerd, therefore we update the y position for next one
    mov %rax, y_name(%rip)
    
    dec %r13                                        #number of printed names gets decremented, also we check to see if we have printed 3 names, if yes return from the function
    cmp $0, %r13
    jg draw_next_name                               #if we still have names to print loop 

name_draw_done:
    pop %r13
    pop %r12
    leave
    ret

#=========================================================

check_collision:
    push %rbp
    mov %rsp, %rbp

    # Load dino position
    mov dino_x(%rip), %r14         # r14 = dino_x
    mov dino_y(%rip), %r15         # r15 = dino_y (fixed-point)
    sar $16, %r15                  # shift right by 16 bits

    # Load ducking flag
    mov is_ducking(%rip), %rax
    test %rax, %rax
    jz not_duck

    # Dino is ducking → smaller height
    mov $10, %rbx                  # dino_width
    mov $6,  %rcx                  # dino_height
    add $4,  %r15                  # adjust y down a bit(adjust hitbox for dino)
    jmp setup

not_duck:
    mov $10, %rbx                  # width
    mov $10, %rcx                  # height

setup:
    lea obstacles(%rip), %r12      # r12 = &obstacles
    mov $MAX_OBSTACLES, %r13       # r13 = loop counter

loop_obstacles:
    # Check if obstacle active
    mov 16(%r12), %rax
    test %rax, %rax
    jz next_obstacle

    # Load obstacle x
    mov (%r12), %rdx
    sar $16, %rdx                  # obstacle_x

    # Load obstacle type
    mov 24(%r12), %rax
    cmp $0, %rax
    je type0
    cmp $1, %rax
    je type1
    cmp $2, %rax
    je type2
    jmp next_obstacle              

type0:
    mov $15, %r8                   # width
    mov $6,  %r9                   # height
    mov $135, %r10                 # y
    jmp check_collision_box

type1:
    mov $10, %r8
    mov $8,  %r9
    mov $140, %r10
    jmp check_collision_box

type2:
    mov $8,  %r8
    mov $12, %r9
    mov $130, %r10

check_collision_box:
    # Horizontal overlap check
    mov %r14, %rax
    add %rbx, %rax                 # dino_x + dino_w
    cmp %rdx, %rax
    jle next_obstacle              # Dino right <= Obstacle left - no collision

    mov %rdx, %rax
    add %r8, %rax                  # obs_x + obs_w
    cmp %r14, %rax
    jle next_obstacle              # Obstacle right <= Dino left - no collision

    # Vertical overlap check
    mov %r15, %rax
    add %rcx, %rax                 # dino_y + dino_h
    cmp %r10, %rax
    jle next_obstacle              # Dino bottom <= Obstacle top - no collision

    mov %r10, %rax
    add %r9, %rax                  # obs_y + obs_h
    cmp %r15, %rax
    jle next_obstacle              # Obstacle bottom <= Dino top - no collision

    #Collision detected
    mov $1, %rax
    leave
    ret

next_obstacle:
    add $32, %r12                  # Move to next obstacle
    dec %r13
    jnz loop_obstacles

    mov $0, %rax                   # No collision
    leave
    ret

#========================================

reset_game:
    push %rbp
    mov %rsp, %rbp

    # Reset all game variables to their starting values 

    movq $0, current_score(%rip)      # start with score = 0
    movq $50, dino_x(%rip)            # put the dino at x = 50 (a bit from the left edge)

    # Dino Y is stored in fixed-point format, so shift it left by 16 bits
    mov $140, %rax                    # normal ground position (pixel value)
    sal $16, %rax                     # convert to fixed-point 
    mov %rax, dino_y(%rip)

    movq $0, velocity_y(%rip)         # no vertical movement yet
    movq $0, is_ducking(%rip)         # dino starts standing (not ducking)

    movq $80000, obst_speed_init_fp(%rip)  # initial obstacle speed (in fixed-point)
    movq $0, spawn_timer(%rip)             # timer for obstacle spawning = 0
    movq $60, spawn_interval(%rip)         # spawn a new obstacle every 60 ticks(for now)
    movq $1000, timer_for_random(%rip)     # seed or counter for randomization

    #  Clear all obstacles from memory 
    lea obstacles(%rip), %rdi          # point to the start of the obstacle array
    mov $MAX_OBSTACLES, %rcx           # number of obstacles to reset

reset_obst_loop:
    movq $0, 0(%rdi)                   # clear obstacle.x
    movq $0, 8(%rdi)                   # clear obstacle.y
    movq $0, 16(%rdi)                  # clear obstacle.active flag
    movq $0, 24(%rdi)                  # clear obstacle.type
    add $32, %rdi                      # move to the next obstacle (each is 32 bytes)
    loop reset_obst_loop               # repeat for all obstacles

    # Clear the screen visually
    mov $0, %rdi                       # parameter (maybe color index or clear flag)
    call clrScreen                     # call your screen-clearing routine

    leave
    ret


#========================================================

# drawRect(x, y, width, height, color)
# rdi=x0, rsi=y0, rdx=width, rcx=height, r8=color
# Clamps to 0–319 and 0–199, fills rectangle using putLine

drawRect:
    push %rbp
    mov  %rsp, %rbp
    sub  $48, %rsp

    cmp $0, %rdx                         #no need to draw 0 dimension rectangle
    jle  done
    cmp $0, %rcx
    jle  done

    mov  %rdi, -8(%rbp)                   # store x start
    mov  %rsi, -16(%rbp)                  # store y start
    mov  %rdi, %rax                # start from x
    add  %rdx, %rax                # add width
    dec  %rax                      
    mov  %rax, -24(%rbp)           # store x end or x1

    mov  %rsi, %rax                # start from y
    add  %rcx, %rax                # add height
    dec  %rax                      
    mov  %rax, -32(%rbp)           # store y end or y1

    mov  %r8,  -40(%rbp)                  # store color

    mov  -16(%rbp), %rax
    cmp  $0, %rax
    jge  y0_ok
    mov  $0, %rax
    mov  %rax, -16(%rbp)                  # if y0 goes off screen 
y0_ok:
    mov  -32(%rbp), %rax
    cmp  $199, %rax
    jle  y1_ok
    mov  $199, %rax
    mov  %rax, -32(%rbp)                  # if y1 goes off screen
y1_ok:
                               

    mov  -8(%rbp), %rax
    cmp  $0, %rax
    jge  x0_ok
    mov  $0, %rax
    mov  %rax, -8(%rbp)                   # if x0 goes off screen
x0_ok:
    mov  -24(%rbp), %rax
    cmp  $319, %rax
    jle  x1_ok
    mov  $319, %rax
    mov  %rax, -24(%rbp)                  # if x1 goes off screen
x1_ok:
    mov  -8(%rbp), %rax
    cmp  -24(%rbp), %rax
    jg   done                             # if x out of range skip drawing

fill_loop:
    mov  -8(%rbp), %rdi                   # x start
    mov  -16(%rbp), %rsi                  # y start
    mov  -24(%rbp), %rdx                  # x end
    mov  -16(%rbp), %rcx                  # y end (same line)
    mov  -40(%rbp), %r8                   # color
    call putLine                          # draw one horizontal line

    mov  -16(%rbp), %rax
    inc  %rax                             # move one pixel down
    mov  %rax, -16(%rbp)
    cmp  -32(%rbp), %rax
    jle  fill_loop                        # repeat until we reach y end

done:
    leave
    ret




# randInRange(min, max) Generates a random integer between [min, max].
# Arguments:
#   rdi = min
#   rsi = max
# Returns:
#   rax = random number in [min, max]
# Updates global variable rand_seed each call.

randInRange:
    # Load the current random seed into RAX
    mov rand_seed(%rip), %rax

    #seed = (seed * 1103515245 + 12345)
    
    imul $1103515245, %rax
    add  $12345, %rax

    # Store the updated seed back into memory
    mov %rax, rand_seed(%rip)

    # Compute the range size: (max - min + 1)
    mov %rsi, %rcx
    sub %rdi, %rcx
    inc %rcx

    # Unsigned divide seed by range size:
    # We only care about the remainder, which is [0, range-1]
    xor %rdx, %rdx
    div %rcx

    # Shift remainder into the desired range: remainder + min
    add %rdi, %rdx

    # Move the final result into RAX for return
    mov %rdx, %rax

    ret

