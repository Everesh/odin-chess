# Rules

A comprehensive list of rules for this chess implementation

## Turn order

Each player can make a single move uppon which's resolution the other player takes inititive

## Movement

Pieces can be moved to a space if
- its not occupied by a piece of the same color
- the path is unobstructed #unless piece is a knight
- space is reachable by a piece according to its move set
- king is not in check or the move will put the king out of check

#### Special moves

###### Innitial pawn move
Pawns can move 2 up if its the first move they would perform

###### En passant
Pawn can capture other pawns as if the initial move was
a normal pawn move the very next turn after it has been used
*I can't be assed to formualte this coherently, you know what enpassant is*

###### Castling
IF the king has not yet moved
&& the coresponding rook has not yet moved
&& the path between the two is empty
&& no enemy piece can move to any space along the path the very next turn
THEN the king can move 2 spaced to that side
&& the coresponding rook gets moved to the other side of the king

## Finishing a game

The game ends if
- A player is put in a mat (win)
- A player is put in a pat (draw)
- Both players have insufficient material to mat (draw)
    - lone kings
    - king and a knight
    - king and a bishop
- A player concedes (win)
- Both players agree to a draw (draw)
- The exact same position appears 3 times (draw) #Not implemented for the sake of my sanity

## Move sets

#### King

1 space in any direction includign diagonals

#### Queen

Any distance in straight or diagonaly

#### Bishop

Any distance diagonaly

#### Knight

An L-shape (2 in a straight line and 1 perpendicularly)

#### Rook

Any distance in straight line

### Pawn

1 space up (from the POV of the controling player)
\* *When capturing 1 up-diagonaly* 