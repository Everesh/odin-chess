# Input

The game will register [algebraic notation](https://en.wikipedia.org/wiki/Algebraic_notation_(chess)), or a save command

## Save command

```
save [uninterupted_string]
```

/* *Will store in saves/(uninterupted_string).yml*

## Load command

On start if a save file is present in `saves/` it will be listed and can be loaded
either via its designated number or file name *without the .yml suffix

```
[1-n | uninterupted_string]
```

## Algebraic notation

```
[piece][starting_position][capture][destination][promotion][check | mat]
```

### piece

Destinguishes which piece is to make a move

| King | Queen | Bishop | Knight | Rook |   Pawn   |
|------|-------|--------|--------|------|----------|
|  K   |   Q   |   B    |   N    |  R   | (empty)  |


### starting_position

Only provided when the move could be performed by ultiple pieces
When both parameters are required the column takes priority

```
[a-h]?[1-8]?
```

### capture

When the move is capturing a pice under your opponents control
the move is denoted by an `x`

```
x
```

### destination

Mandatory element describing the destination
Column has the priority over row

```
[a-h][1-8]
```

### promotion

If the move is putting a pawn at the end of the column
promotion is needed in the form of `=(piece_name)`

```
=([QBNR])
```

### Check

If the move would put the enemy king into a check a `+` is appended

```
+
```

### Mat

If the move is putting the enemy king into a mat a `#` is appened
and the game concludes

```
#
```