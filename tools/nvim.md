# NeoVim

## Installation

Follow the [Youtube tutorial](https://www.youtube.com/watch?v=E2mKJ73M9pg).

```shell
sudo dnf install -y neovim python3-neovim
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
```
## Setup


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
| `o` | Enter insert mode **at the new line** below the cursor |
| `O` | Enter insert mode **at the new line** above the cursor |
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
| `^` `0` | Move to beginning of the current line |
| `gg` | Move to the beginning of the file |
| `G` | Move to the end of the file |
| `%` | Jump between matching brackets `()`, `{}`, `[]` |


### File tree (NvimTree)

| Command | Description |
| --- | --- |
| `CTRL + n` | Open/close the sidebar |

### Fuzzy Finder

| Command | Description |
| --- | --- |
| `<_>ff` | Find Files by name in current project |
| `<_>fw` | Live Grep (search text across all project files) |
