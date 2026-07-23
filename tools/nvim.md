# NeoVim

## Commands

### Opening files

```shell
nvim path/to/file

# Open file at line 18
nvim +18 path/to/file
```
### Modes

| Command | Description |
| --- | --- |
| `i` | Enter insert mode **at** the cursor |
| `I` | Enter insert mode at the **beginning** of the line |
| `a` | Enter insert mode **after** the cursor |
| `ESC` | Exit insert mode |

### Move

| Command | Description |
| --- | --- |
| `h`, `j`, `k`, `l` | left, down, up, right |
| `w` / `b` | Jump forward/backward by word |
| `W` / `B` | Jump by whitespace-delimited (bigger jumps) |
| `20G` | Go to line 20 |
| `:20`	| Also go to line 20 (command-line style) |
| `:$` | Go to the last line of the file |
| `$` | Move to end of the current line |
| `^` | Move to beginning of the current line |

