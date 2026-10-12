.file "src/game/data.s"

.section .game.data

# leaderboard & player name data


leaderboard_data:
    .ascii "--------"         # player 1 name (8 chars, placeholder '-')
    .quad 0                   # player 1 score
    .ascii "--------"         # player 2 name
    .quad 0                   # player 2 score
    .ascii "--------"         # player 3 name
    .quad 0                   # player 3 score

player_name:          .ascii "        "   # 8-char buffer for new name input
name_cursor:          .quad 0            # current cursor position while typing
high_score_rank:      .quad -1           # -1 = no new highscore
name_entry_complete:  .quad 0            # 0 = typing, 1 = finished entering name


# score display and layout variables


location_score:       .quad 0            # x position where score is drawn
digits_y:             .quad 0            # y position for score drawing

names_written:        .quad 0            # helper for leaderboard printing

x_start_name:         .quad 60           # x start for first name character
y_name:               .quad 90           # y start for first name line
name_char_counter:    .quad 0            # tracks letters drawn per name


# game state constants


STATE_MENU        = 0                    # main menu
STATE_PLAYING     = 1                    # in-game
STATE_GAME_OVER   = 2                    # game over screen
STATE_LEADERBOARD = 3                    # leaderboard display



# main state and gameplay data


game_state:        .quad 0               # current game state
current_score:     .quad 0               # player score counter
selected:          .quad 0               # selected menu option
menu_init:         .quad 0               # menu initialization flag

leader_init:       .quad 0               # leaderboard init flag


# dino physics and position data


dino_x:            .quad 50              # starting x position
dino_y:            .quad 300000          # starting y (fixed-point format)
is_ducking:        .quad 0               # ducking state (0 = no, 1 = yes)

gravity:           .quad 32200           # gravity acceleration (fixed-point)
velocity_y:        .quad 0               # current vertical speed
ground_y:          .quad 150             # y coordinate of ground line


# random generation and obstacle control


rand_seed:         .quad 123456789       # seed for randInRange

MAX_OBSTACLES = 8                        # maximum number of obstacles


obstacles:
    .rept MAX_OBSTACLES
    .quad 0                              # obstacle.x
    .quad 0                              # obstacle.speed
    .quad 0                              # obstacle.active flag
    .quad 0                              # obstacle.type
    .endr

obst_spawn_x_fp:     .quad 20250624      # x start position for new obstacle in fixed point(rightmost point of screen)
obst_speed_init_fp:  .quad 65536        # initial obstacle speed
obst_accel_fp:       .quad 100           # obstacle acceleration

spawn_timer:         .quad 0             # current spawn timer
spawn_interval:      .quad 60            # frames between spawns
timer_for_random:    .quad 1000          # random spawn tracker
