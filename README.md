# BF zig interpreter

![example](example.png)

## Rules
- \> move cell pointer forward
- < move cell pointer backward
- \+ increment current cell
- \- decrement current cell
- , take a character as input and assign to current cell
- . output character value of current cell
- [ start loop
- ] end loop if current cell is zero

## Using

#### First build with the steps above

#### Then move the executable build from zig-cache/bin/ to your path

```
<execname> examples/mandel.bf
```

## Building

#### For fastest build

```shell
zig build -Drelease-small
```

#### For debug build

```shell
zig build
```

