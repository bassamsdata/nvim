- Reorganize the configuration files
- choose custom random colorschem every time nvim starts
- check wich plugin makes the crolling bad
- average age for managers in each year and see how it changes over time

## add these highlioghts to all the colorschemes I use:
- Arrow highlights

# make this modules:
- [ ] yanking plugin
- [ ] usage time
- [ ] snowflakes
- [x] Auto save if diagnostics.count() is nil. (see n-macro for this)

## make this into small module:
https://stackoverflow.com/questions/11634804/vim-auto-resize-focused-window
:let &winheight = &lines * 7 / 10
:autocmd WinEnter * execute winnr() * 2 . 'wincmd _'
https://stackoverflow.com/questions/61243238/how-do-i-make-window-splits-maintain-consistent-sizing-with-the-current-as-large
https://github.com/kwkarlwang/bufresize.nvim/blob/master/lua/bufresize.lua



[!File: `utils/colorUtils.go`]
```go
package utils

import (
	"fmt"
	"image"
	"os"

	colorkit "github.com/gookit/color"

	"github.com/cenkalti/dominantcolor"
)
```
