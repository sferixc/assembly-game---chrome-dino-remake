    .extern play, leaderboard, arrow, BIRD

.global gameInit
.global gameLoop

.section .game.text

gameInit:
    mov $0, %rdi
    call clrScreen

    mov $0, %rdi
    mov $0xFFFFFF, %rsi #white
    call setPallette
    mov $1, %rdi
    mov $0x00A6D6, %rsi #blue
    call setPallette
    mov $2, %rdi
    mov $0x000000, %rsi #black
    call setPallette
    mov $3, %rdi
    mov $0x008000, %rsi #green
    call setPallette
    
    mov $4,  %rdi
    mov $0xFF0000, %rsi      # red
    call setPallette

    mov $5,  %rdi
    mov $0xFFA500, %rsi      # orange
    call setPallette

    mov $6,  %rdi
    mov $0xFFFF00, %rsi      # yellow
    call setPallette

    mov $7,  %rdi
    mov $0x800080, %rsi      # purple
    call setPallette

    mov $8,  %rdi
    mov $0xFF00FF, %rsi      # magenta
    call setPallette

    mov $9,  %rdi
    mov $0xFFC0CB, %rsi      # pink
    call setPallette

    mov $10, %rdi
    mov $0x8B4513, %rsi      # saddle brown
    call setPallette

    mov $11, %rdi
    mov $0x00FF00, %rsi      # lime
    call setPallette

    mov $12, %rdi
    mov $0x008080, %rsi      # teal
    call setPallette

    mov $13, %rdi
    mov $0x000080, %rsi      # navy
    call setPallette

    mov $14, %rdi
    mov $0x800000, %rsi      # maroon
    call setPallette

    mov $15, %rdi
    mov $0x808000, %rsi      # olive
    call setPallette

    mov $16, %rdi
    mov $0xFFD700, %rsi      # gold
    call setPallette

    mov $17, %rdi
    mov $0x9400D3, %rsi      # dark violet
    call setPallette

    mov $18, %rdi
    mov $0x808080, %rsi      # gray
    call setPallette



    lea obstacles(%rip), %rdi
    mov $MAX_OBSTACLES, %rcx
.init_obst_loop:
    movq $0, 0(%rdi)
    movq $0, 8(%rdi)
    movq $0, 16(%rdi)
    movq $0, 24(%rdi)
    add $32, %rdi
    loop .init_obst_loop

    ret

gameLoop:
    mov game_state(%rip), %rax
    
    cmp $STATE_PLAYING, %rax
    je handle_playing
    
    cmp $STATE_MENU, %rax
    je handle_menu
    
    cmp $STATE_GAME_OVER, %rax
    je handle_game_over
    
    cmp $STATE_LEADERBOARD, %rax
    je handle_leaderboard
    
    


