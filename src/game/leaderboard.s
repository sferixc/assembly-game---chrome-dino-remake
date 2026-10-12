.file "src/game/leaderboard.s"

handle_leaderboard:
    mov leader_init(%rip), %rax
    cmp $1 ,%rax
    je leader_is_init                      # check if leaderboard screen already initialized

    movq $1, leader_init(%rip)             # mark leaderboard as initialized

    mov $0, %rdi
    call clrScreen                         # clear the screen before drawing anything

    # draw static labels for "NAME" and "SCORE"
    lea NAME(%rip), %rdi
    mov $75, %rsi
    mov $40, %rdx
    call putBitmap

    lea SCORE(%rip), %rdi
    mov $180, %rsi
    mov $40, %rdx
    call putBitmap

    # draw the position numbers (1, 2, 3) on the left side
    lea DIGIT1(%rip), %rdi
    mov $50, %rsi
    mov $90, %rdx
    call putBitmap

    lea DIGIT2(%rip), %rdi
    mov $50, %rsi
    mov $105, %rdx
    call putBitmap

    lea DIGIT3(%rip), %rdi
    mov $50, %rsi
    mov $120, %rdx
    call putBitmap

    # draw player names from leaderboard
    call putNames

    # set starting position for score printing (x location)
    mov $240, %rax
    mov %rax, location_score(%rip)
    
    # print scores for the 3 leaderboard entries
    lea leaderboard_data(%rip), %r9

    # print top 1 score
    mov 8(%r9), %rax
    mov %rax, current_score(%rip)
    movq $90, digits_y(%rip)
    push %r9
    call display_score
    pop %r9

    # print top 2 score
    add $16, %r9
    mov 8(%r9), %rax
    mov %rax, current_score(%rip)
    movq $105, digits_y(%rip)
    push %r9
    call display_score
    pop %r9

    # print top 3 score
    add $16, %r9
    mov 8(%r9), %rax
    mov %rax, current_score(%rip)
    movq $120, digits_y(%rip)
    call display_score

leader_is_init:
    call ps2_getkey                        # get keyboard input
    cmp $0, %r8
    je wait_key_leader                     # if no key pressed, wait

    call ps2_translate_scancode            # translate scan code
    cmp $49, %r8                           # check if key '1' was pressed
    jne wait_key_leader                    # if not, keep waiting
    
    # reset state flags when leaving leaderboard
    movq $0, leader_init(%rip)
    movq $0, menu_init(%rip)
    movq $0, game_state(%rip)

wait_key_leader:
    ret
