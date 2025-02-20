# Tic-Tac-Toe in x86-64 Assembly (NASM)

## Overview
This is a command-line Tic-Tac-Toe game written in **x86-64 Assembly** using **NASM** for Linux. It allows two players to take turns placing their marks (X or O) on a 3x3 board until one player wins or the game ends in a draw.

## Features
- **Two-player mode**: Players alternate turns.
- **Text-based UI**: The game board is displayed in the terminal.
- **Win detection**: The game checks for a winner after each move.
- **Draw detection**: If all positions are filled and no player has won, the game ends in a draw.

## Requirements
- **NASM (Netwide Assembler)**: To assemble the code.
- **Linux (x86-64)**: The program is designed to run on Linux.

## Installation
1. Install NASM if not already installed:
   ```sh
   sudo apt install nasm  # Debian/Ubuntu
   sudo yum install nasm  # Fedora
   ```
2. Clone or download the source code.
3. Assemble the program:
   ```sh
   nasm -f elf64 tic_tac_toe.asm -o tic_tac_toe.o
   ```
4. Link the object file:
   ```sh
   ld tic_tac_toe.o -o tic_tac_toe
   ```

## Usage
Run the program in the terminal:
```sh
./tic_tac_toe
```
Follow the on-screen prompts to play the game.

## How It Works
- The board is represented in memory.
- System calls (`sys_write`, `sys_read`) handle input and output.
- The program processes user input, updates the board, and checks for a winner.
- The game loops until a win or draw condition is met.

## Controls
- Enter a number (1-9) to place your mark in the corresponding position.
- The board positions are arranged as follows:
  ```
  1 | 2 | 3
  ---------
  4 | 5 | 6
  ---------
  7 | 8 | 9
  ```
- Players take turns entering numbers.

## Example Gameplay
```
Player X, enter your move: 1

X |   |  
---------
  |   |  
---------
  |   |  

Player O, enter your move: 5

X |   |  
---------
  | O |  
---------
  |   |  
```

## License
This project is open-source and available under the MIT License.

