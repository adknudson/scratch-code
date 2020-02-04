import numpy as np
import time
import os
"""
Tic-Tac-Toe
Written by Alex Knudson
"""


def clear():
    return os.system('cls')


"""
Input
--------------------
The user is encouraged to use the numpad as input because it is already in a
3x3 array. So an input of '9' corresponds to the upper right corner. This
input gets mapped to a position in a 3x3 numpy array.
"""
input_map = {'1': (2, 0), '2': (2, 1), '3': (2, 2),
             '4': (1, 0), '5': (1, 1), '6': (1, 2),
             '7': (0, 0), '8': (0, 1), '9': (0, 2)}

"""
Board Template
--------------------
This variable contains the board template along with a guide for move input.
"""
template = r"""
 {} │ {} │ {}         7 │ 8 │ 9
───┼───┼───       ───┼───┼───
 {} │ {} │ {}         4 │ 5 │ 6
───┼───┼───       ───┼───┼───
 {} │ {} │ {}         1 │ 2 │ 3
"""

bye = r"""
             *     ,MMM8&&&.            *
                  MMMM88&&&&&    .
                 MMMM88&&&&&&&
     *           MMM88&&&&&&&&
                 MMM88&&&&&&&&
                  MMM88&&&&&&
                    MMM8&&&      *
          |\___/|
          )     (             .
         =\     /=
           )===(            Thanks for playing   *
          /     \
          |     |
         /       \
         \       /
  _/\_/\_/\__  _/_/\_/\_/\_/\_/\_/\_/\_/\_/\_
  |  |  |  |( (  |  |  |  |  |  |  |  |  |  |
  |  |  |  | ) ) |  |  |  |  |  |  |  |  |  |
  |  |  |  |(_(  |  |  |  |  |  |  |  |  |  |
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  |  | ASCII art by /u/Metalcat125 |  |  |  |
"""


def play(p1_name, p2_name):
    """Set up the game with initial board states"""
    score_board = np.zeros((3, 3)).astype(np.int)
    M = np.array([[8, 1, 6], [3, 5, 7], [4, 9, 2]]).astype(np.int)
    positions = np.empty((3, 3)).astype(str)
    positions[:] = ' '
    winner = False

    for i in range(5, 0, -1):
        clear()
        print("{} is X and {} is O" .format(p1_name, p2_name))
        print("Game is starting in {}" .format(i))
        time.sleep(1)

    player = ((p1_name, 1, 'X'), (p2_name, -1, 'O'))

    for move_number in range(9):

        print_board(template, positions)

        # Get player number
        p_num = move_number % 2

        while True:
            # Get input from player
            move = input("{}, please enter your move [1-9]\n"
                         .format(player[p_num][0]))

            # Ensure that the input is an integer
            try:
                int(move)
            except ValueError:
                print("Sorry, but your input was not a valid number.")
                continue

            # If the user accidentally hits enter, retry input
            if move == '':
                continue
            # If the input is not in range of 1-9, retry
            elif int(move) not in [x + 1 for x in range(9)]:
                print("Sorry, your move is not recognized.")
                continue
            # If the position is already taken
            elif positions[input_map[move]] != ' ':
                print("Sorry, that spot is already taken.")
                continue
            # No issues, so we'll accept the input
            else:
                break

        # Update board positions
        # Set scoreboard (+/- 1)
        score_board[input_map[move]] = player[p_num][1]
        # Update positions
        positions[input_map[move]] = player[p_num][2]

        # Check for winner
        winner, winner_name = check_for_winner(M, score_board, player)
        if winner:
            print_board(template, positions)
            print("{} is the winner!" .format(winner_name))
            break

    if not winner:
        print_board(template, positions)
        print("Game ended in a tie")


def print_board(template, positions):
    """
    Print Board
    --------------------
    The board state is stored in a 3x3 array. Here it gets flattened and sent
    to a list where it can be formatted into the board template.
    """
    clear()
    print(template.format(*positions.flatten().tolist()))


def check_for_winner(magic, score_board, players):
    """
    Check for Winner
    --------------------
    This function uses a magic square to check if there is a winner.
    The logic is that any 3 consecutive cells in the matrix will add up to 15.
    So when a move is made, the score_board will enter a 1 or -1, which gets
    elementwise multiplied by the magic square. If any of the sums are 15, then
    Player 1 is the winner, and likewise if any of the sums are -15, then
    Player 2 is the winner. This is not the most readable solution, but I think
    it is pretty unique!
    """
    S = np.multiply(magic, score_board)

    if (15 in S.sum(axis=0)) or (15 in S.sum(axis=1)) or (15 == S.trace()) or (15 == S[::-1].trace()):
        return True, players[0][0]
    elif (-15 in S.sum(axis=0)) or (-15 in S.sum(axis=1)) or (-15 == S.trace()) or (-15 == S[::-1].trace()):
        return True, players[1][0]
    else:
        return False, None


def main():
    # Get names in the beginning. Don't want to keep asking for them
    p1_name = input('Player 1 name: ')
    p2_name = input('Player 2 name: ')

    while True:
        play(p1_name, p2_name)

        print("Play again? [Y/n]")
        play_again = input()
        if not play_again.lower().startswith('y'):
            clear()
            print(bye)
            time.sleep(5)
            break


if __name__ == "__main__":
    main()
