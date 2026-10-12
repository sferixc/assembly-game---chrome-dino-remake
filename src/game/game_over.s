.file "src/game/game_over.s"

handle_game_over:
    push %rbp
    mov %rsp, %rbp

    # check if the player's score has already been compared to leaderboard
    mov high_score_rank(%rip), %rax
    cmp $-1, %rax
    jne already_checked_score                # if already checked, skip

    call check_high_score                    # check current score vs leaderboard
    mov %rax, high_score_rank(%rip)          # store the resulting rank (-1 if none)

    movq $0, name_cursor(%rip)               # start name entry cursor at 0
    movq $0, name_entry_complete(%rip)       # mark name entry as incomplete

    lea player_name(%rip), %rdi              # fill player_name with spaces
    movq $0x20202020, (%rdi)




already_checked_score:
    mov $0, %rdi
    call clrScreen                           # clear the screen before drawing

    mov high_score_rank(%rip), %rax
    cmp $-1, %rax
    je display_normal_game_over              # if not a highscore, show normal over screen
    jmp display_highscore_game_over          # otherwise handle name entry for highscore


# regular game over (no leaderboard update)

display_normal_game_over:
    lea GAME_OVER(%rip), %rdi
    mov $80, %rsi
    mov $50, %rdx
    call putBitmap                           # draw "GAME OVER" text

    mov $170, %rax
    mov %rax, location_score(%rip)
    mov $120, digits_y(%rip)
    call display_score                       # display final score

    call ps2_getkey
    cmp $0, %r8
    je game_over_done                        # if no key pressed, wait
    call ps2_translate_scancode

    cmp $32, %r8                             # space key
    je restart_game_from_over
    cmp $49, %r8                             # key '1'
    je back_to_menu_from_over

    jmp game_over_done


# game over with high score (name entry mode)

display_highscore_game_over:
    mov name_entry_complete(%rip), %rax
    cmp $1, %rax
    je name_done_wait_input                  # if name already entered, skip input

    lea HIGHSCORE_DRAW(%rip), %rdi
    mov $85, %rsi
    mov $80, %rdx
    call putBitmap                           # draw "NEW HIGHSCORE" message

    call ps2_getkey
    cmp $0, %r8
    je game_over_done                        # wait for key press
    call ps2_translate_scancode

    cmp $32, %r8
    je set_before                            # space → finish name early
    cmp $49, %r8
    je back_to_menu_from_over                # '1' → back to menu

    cmp $65, %r8
    jl game_over_done                        # below 'A' → invalid
    cmp $122, %r8
    jg game_over_done                        # above 'z' → invalid

    cmp $97, %r8
    jl already_uppercase                     # if uppercase skip
    sub $32, %r8                             # convert lowercase to uppercase

already_uppercase:
    mov name_cursor(%rip), %rcx
    cmp $8, %rcx
    jge game_over_done                       # stop if name full (max 8 chars)

    lea player_name(%rip), %rdi
    add %rcx, %rdi
    mov %r8b, (%rdi)                         # write letter to name buffer

    inc %rcx
    mov %rcx, name_cursor(%rip)              # move to next letter position

    cmp $8, %rcx
    jne game_over_done                       # if name not full, continue

    movq $1, name_entry_complete(%rip)       # mark entry complete
    call insert_into_leaderboard             # insert into leaderboard
    jmp game_over_done


# finish name entry early by pressing space

set_before:
    mov $1, name_entry_complete(%rip)
    call insert_into_leaderboard
    jmp game_over_done


# name entry complete, now wait for restart or menu key

name_done_wait_input:
    mov $160, location_score(%rip)
    call display_score                       # show final score again

    call ps2_getkey
    cmp $0, %r8
    je game_over_done
    call ps2_translate_scancode

    cmp $32, %r8                             # space
    je restart_game_from_over
    cmp $49, %r8                             # '1'
    je back_to_menu_from_over
    jmp game_over_done


# restart the game from game over screen

restart_game_from_over:
    movq $-1, high_score_rank(%rip)          # reset highscore flag
    call reset_game
    movq $1, game_state(%rip)                # set state to "in game"
    jmp game_over_done


# return to menu from game over screen

back_to_menu_from_over:
    movq $-1, high_score_rank(%rip)          # reset highscore flag
    movq $0, menu_init(%rip)
    movq $0, game_state(%rip)                # set state to "menu"
    jmp game_over_done



game_over_done:
    leave
    ret
