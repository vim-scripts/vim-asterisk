vim-asterisk: * -Improved
========================
[![](https://img.shields.io/github/release/haya14busa/vim-asterisk.svg)](https://github.com/haya14busa/vim-asterisk/releases)
[![](http://img.shields.io/github/issues/haya14busa/vim-asterisk.svg)](https://github.com/haya14busa/vim-asterisk/issues)
[![](http://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![](http://img.shields.io/badge/doc-%3Ah%20asterisk.txt-red.svg)](doc/asterisk.txt)

Introduction
------------

asterisk.vim provides improved * motions.

### 1. stay star motions (z prefixed mappings)
z star motions doesn't move your cursor.

### 2. visual star motions
Search selected text.

### 3. Use smartcase unlike default one
Default behavior, which see ignorecase and not smartcase, is not intuitive.

Installation
------------

[Neobundle](https://github.com/Shougo/neobundle.vim) / [Vundle](https://github.com/gmarik/Vundle.vim) / [vim-plug](https://github.com/junegunn/vim-plug)

```vim
NeoBundle 'haya14busa/vim-asterisk'
Plugin 'haya14busa/vim-asterisk'
Plug 'haya14busa/vim-asterisk'
```

[pathogen](https://github.com/tpope/vim-pathogen)

```
git clone https://github.com/haya14busa/vim-asterisk ~/.vim/bundle/vim-asterisk
```

Usage
-----

```vim
map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)
```

If you want to set "z" (stay) behavior as default

```vim
map *  <Plug>(asterisk-z*)
map #  <Plug>(asterisk-z#)
map g* <Plug>(asterisk-gz*)
map g# <Plug>(asterisk-gz#)
```

Special thanks
--------------
|asterisk.vim| uses the code from vim-visualstar for visual star feature.

- Author: thinca (https://github.com/thinca)
- Plugin: https://github.com/thinca/vim-visualstar

Author
------
haya14busa (https://github.com/haya14busa)

