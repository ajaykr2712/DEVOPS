# Vim Concepts Cheat Sheet

## Basics
- **Open a file**: `vim filename`
- **Exit Vim**:
  - Save and exit: `:wq` or `ZZ`
  - Exit without saving: `:q!`
- **Insert Mode**: Press `i` to enter, `<Esc>` to exit.
- **Command Mode**: Default mode; navigate and execute commands.

---

## Navigation
- **Move cursor**:
  - Characters: `h` (left), `l` (right)
  - Lines: `j` (down), `k` (up)
- **Word navigation**:
  - Start of next word: `w`
  - End of next word: `e`
  - Start of previous word: `b`
- **Paragraph navigation**:
  - Next: `}` 
  - Previous: `{`
- **Screen navigation**:
  - Half-screen down: `Ctrl+d`
  - Half-screen up: `Ctrl+u`

---

## Editing
- **Delete**:
  - Character: `x`
  - Line: `dd`
  - Word: `dw`
  - From cursor to end of line: `D`
- **Undo/Redo**:
  - Undo: `u`
  - Redo: `Ctrl+r`
- **Copy/Paste**:
  - Copy (yank) line: `yy`
  - Paste: `p`
- **Replace**:
  - Replace a single character: `r<char>`
  - Replace from the cursor: `R` (overwrite mode)

---

## Search and Replace
- **Search**:
  - Forward: `/pattern`
  - Backward: `?pattern`
  - Next occurrence: `n`
  - Previous occurrence: `N`
- **Replace**:
  - Current line: `:s/old/new/g`
  - Entire file: `:%s/old/new/g`

---

## Visual Mode
- **Activate**:
  - Character selection: `v`
  - Line selection: `V`
  - Block selection: `Ctrl+v`
- **Edit selection**:
  - Delete: `d`
  - Yank: `y`
  - Replace: `r`

---

## Split Windows
- **Horizontal split**: `:split filename` or `Ctrl+w s`
- **Vertical split**: `:vsplit filename` or `Ctrl+w v`
- **Navigate splits**: `Ctrl+w <direction>` (`h`, `j`, `k`, `l`)
- **Resize splits**:
  - Increase: `Ctrl+w +`
  - Decrease: `Ctrl+w -`

---

## Buffers and Tabs
- **Buffers**:
  - List buffers: `:ls`
  - Switch buffer: `:b<number>`
  - Close buffer: `:bd`
- **Tabs**:
  - New tab: `:tabnew filename`
  - Next tab: `:tabn`
  - Previous tab: `:tabp`
  - Close tab: `:tabclose`

---

## Macros
- **Record macro**: `q<register>`
- **Stop recording**: `q`
- **Play macro**: `@<register>`
- **Repeat macro**: `@@`

---

## Advanced
- **Indentation**:
  - Indent: `>>`
  - Outdent: `<<`
- **Marks**:
  - Set mark: `m<char>`
  - Jump to mark: `'char`
- **Folding**:
  - Create fold: `zf`
  - Open fold: `zo`
  - Close fold: `zc`

---

## Customization
- **Edit settings**: `:e ~/.vimrc`
- **Set options**:
  - Line numbers: `:set number`
  - Syntax highlighting: `:syntax on`
- **Plugins**: Use a plugin manager like `vim-plug` for additional features.

---

## Useful Commands
- **Jump to line**: `:<line_number>`
- **Repeat last command**: `.`
- **Show current file info**: `Ctrl+g`

---

Mastering Vim takes practice. Start with these concepts and gradually explore more advanced features.
