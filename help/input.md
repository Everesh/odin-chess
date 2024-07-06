# Input

The game will register [algebraic notation](https://en.wikipedia.org/wiki/Algebraic_notation_(chess)), or a save command

## Save command

```
save
```

A subsequent prompt will ask you to provide your desired file name (string devoid of whitespace characters)

/* *Will store in saves/(uninterupted_string).yml*

## Load command

On start if at least a single save file is present in `saves/` they will all be listed and can be loaded via their designated number

```
[1-n]
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

Only provided when the move could be performed by multiple pieces
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
promotion is needed in the form of `=piece_name`

```
=[QBNR]
```

### Check

If the move would put the enemy king into a check a `+` needs to be appended

```
+
```

### Mat

If the move is putting the enemy king into a mat a `#` needs to be appened and the game concludes

```
#
```