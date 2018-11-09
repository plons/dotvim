dotvim
======

personal vim configuration

- [Installation](#installation)
- [Documentation](#documentation)
    - [Movement](#movement)
    - [Gdb](#gdb)


# <a name=installation>Installation

* clone the repository to your home directory
* run the *install.sh* script

# <a name=documentation>Documentation

## <a name=movement>Movement

|   |   |   |
|---|---|---|
|   | k |   |
| h |   | l |
|   | j |   |

* `w ` goto begin of next word (word->characters separated by spaces or special characters (',', ';', ...))
* `W ` goto begin of next WORD (WORD->characters separated by spaces)
* `e ` go forward to end of word
* `b ` go backward to begin of word
* `0 ` goto begin of line
* `$ ` goto end of line
* `^ ` goto first character of line
* `gf` goto file (under cursor)
* `gg` goto line default first line
* `G ` goto line default last line


## <a name=gdb>GDB

Using [Pyclewn](http://pyclewn.sourceforge.net/_static/pyclewn.html)
* http://pyclewn.sourceforge.net/install.html
* https://github.com/tpope/vim-pathogen

Download pyclewn
```bash
sudo pip install pyclewn
cd ~/.vim/bundle
python -c "import clewn; clewn.get_vimball()"
vim pyclewn-2.x.vmb
```

Load vimball
```vim
:!mkdir ~/.vim/bundle/vim-pyclewn
:UseVimball ~/.vim/bundle/vim-pyclewn
```

### Debug session
 * `:Pyclewn` Start pyclewn from Vim
 * `:Cfile path/to/executable`
 * `:Cmapkeys`
   *  `CTRL-B`  set a breakpoint on the line where the cursor is located
   *  `CTRL-E`  clear all breakpoints on the line where the cursor is located
 * `:Crun` / `:Cstart` (stops at main)
   *  `CTRL-N`  next: next source line, skipping all function calls
   *  `CTRL-Z`  send an interrupt to gdb and the program it is running (unix only)
   *  `B     `  info breakpoints
   *  `L     `  info locals
   *  `A`    `  info args
   *  `S     ` step
   *  `CTRL-N` next: next source line, skipping all function calls
   *  `F     ` finish
   *  `R     ` run
   *  `Q     ` quit
   *  `C     ` continue
   *  `W     ` where
   *  `X     ` foldvar
 * `:Cprint myVariable->someState()`
 * `:Cexitclewn`
