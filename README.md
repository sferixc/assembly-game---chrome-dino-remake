# Dino Runner

A Chrome Dino-inspired game written in x86-64 Assembly using gamelib-x64. Jump over cacti, duck under birds, and try to get the highest score. The game gradually speeds up and tracks the top three scores for the session.

## Running

You need Linux x86-64, GNU Make, GNU binutils, and QEMU (`qemu-system-x86_64`). From the project folder, run:

```bash
make qemu
```

This builds the game and launches it in QEMU.

## Controls

- **W / S** — select a menu option.
- **Space** — confirm a menu option, jump, or restart after Game Over.
- **S** — toggle ducking during gameplay.
- **1** — return to the menu.

If you reach the leaderboard, type your name and press **Space** to confirm.

## License

Based on gamelib-x64, created for the Computer Organization course at TU Delft.
Copyright (C) 2014 Otto Visser, Tim Hegeman. Licensed under GPL-3.0 or later; see [LICENSE](LICENSE).
