.file "src/game/menu.s"

handle_menu:
    mov menu_init(%rip), %rax
    cmp $2, %rax
    je skip_clear                            # if already drawn skip redraw

    mov $0, %rdi
    call clrScreen                           # clear the screen before drawing menu

    # draw play button box
    mov $110, %rdi                           # x position
    mov $30, %rsi                            # y position
    mov $100, %rdx                           # width
    mov $40, %rcx                            # height
    mov $2, %r8                              # color index
    call drawRect

    # draw leaderboard button box
    mov $110, %rdi
    mov $130, %rsi
    mov $100, %rdx
    mov $40, %rcx
    mov $2, %r8
    call drawRect

    # draw "PLAY" text
    leaq play(%rip), %rdi
    mov $110, %rsi
    mov $30, %rdx
    call putBitmap

    # draw "LEADERBOARD" text
    leaq leaderboard(%rip), %rdi
    mov $110, %rsi
    mov $130, %rdx
    call putBitmap

    mov menu_init(%rip), %rax
    inc %rax
    mov %rax, menu_init(%rip)                # increase menu_init to track setup state

skip_clear:

# draw selection arrow based on selected item

draw_other_stuff_menu:
    mov selected(%rip), %rax
    cmp $1, %rax
    je draw_arrow_lb                         # if selected == 1 → draw arrow at leaderboard

    # clear old arrow at leaderboard
    mov $30, %rdi
    mov $130, %rsi
    mov $40, %rdx
    mov $40, %rcx
    mov $0, %r8
    call drawRect

    # draw arrow at play option
    leaq arrow(%rip), %rdi
    mov $30, %rsi
    mov $30, %rdx
    call putBitmap
    jmp check_keys

draw_arrow_lb:
    # clear old arrow at play
    mov $30, %rdi
    mov $30, %rsi
    mov $40, %rdx
    mov $40, %rcx
    mov $0, %r8
    call drawRect

    # draw arrow at leaderboard option
    leaq arrow(%rip), %rdi
    mov $30, %rsi
    mov $130, %rdx
    call putBitmap

# check keyboard input to move between menu items

check_keys:
    call ps2_getkey
    cmp $0, %r8
    je done_menu                             # no key pressed - do nothing

    call ps2_translate_scancode              # translate the key into ascii value

    cmp $119, %r8                            # check for 'w' key
    jne check_s
    movq $0, selected(%rip)                  # move selection up (to "play")
    jmp done_menu

check_s:
    cmp $115, %r8                            # check for 's' key
    jne check_space1
    movq $1, selected(%rip)                  # move selection down (to "leaderboard")
    jmp done_menu

check_space1:
    cmp $32, %r8                             # check for spacebar
    jne done_menu

    movq $0, menu_init(%rip)                 # reset menu state for next time

    mov selected(%rip), %rax
    cmp $1, %rax
    je go_leaderboard                        # if selected == leaderboard, jump there

    ##if play selected reset and start game
    call reset_game
    movq $1, game_state(%rip)                # set game state to "in game"
    jmp done_menu

go_leaderboard:
    movq $3, game_state(%rip)                # set game state to leaderboard screen

done_menu:
    ret
