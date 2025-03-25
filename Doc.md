# Doc

## Cursor Control

`w` - move one cell up

`s` - move one cell down

`a` - move one cell left

`d` - move one cell right

`e` - change the state of the current cell

## Element Description

### Cursor

Takes a 7-bit ASCII character code as input. Then it compares it with the codes of the `w, a, s, d` characters. After that, it updates the current X or Y coordinate by 1. The result is stored in a register for further use. The result is output as 5-bit X and Y values.

### Write buffer

Takes a 5-bit row number, a 32-bit string for writing, a 1-bit write signal, a 1-bit signal for clearing the entire buffer, and a 5-bit value for compressing the game field. The tunnels `block1 - block15` provide signals for locking and resetting the registers when compressing the game area vertically. 32-bit masks are used to compress the area horizontally. The `row` input is used to select one of the 32 registers to store the new row.

### Converter

Takes 32 lines of 32 bits and 5-bit X and Y values. A multiplexer selects the required line, and a decoder selects the required bit in the line. Then using XOR, the bit at position X in line Y is toggled.

### Buffer

Has 32 inputs and outputs of 32 bits each, and a 1-bit input for updating the state of the registers. It serves as an intermediate link for saving the matrix state.

### Zone shrinker

Receives a 4-bit number as input (number of generations in the game). For each generation, there is a 32-bit mask for adding columns on the left and right of the LED matrix. Using an OR gate, we raise the needed bits and keep those that have already been raised. To add the top and bottom borders on the LED matrix, we use two constants, border1 and border2, where border1 is the number of generations extended to 32 bits, and border2 is 33 minus border1. Then we simply compare the row number of the matrix up to 14 with border1, and from 17 with border2. If the row number is less than or equal to border1, we raise all bits; otherwise, we leave the row unchanged. The same applies to border2. We select the correct value after the operations using a multiplexer, where the first cell contains the unchanged row and the second one contains a 32-bit constant with all bits raised.

### Cursor visualization

Receives 32 rows of 32 bits, and 5-bit X and Y values. Also a 1-bit input for enabling or disabling cursor visualization. A multiplexer selects the row with index Y. Using a decoder, the bit at index X is selected. Then an OR gate merges the row with the selected bit. Then using multiplexers, the new row replaces the current row at the selected output. Comparators are used to choose whether to replace the row or not.