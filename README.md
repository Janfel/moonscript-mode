# moonscript-mode

## Overview

A basic major mode for editing [MoonScript](http://moonscript.org/), a
preprocessed language for [Lua](https://www.lua.org/) which shares
many similarities with [CoffeeScript](http://coffeescript.org/).

Also includes a very basic major mode for the experimental
[MoonScript REPL](https://github.com/leafo/moonscript/wiki/Moonscriptrepl).

## History

This mode started out as a modification of stuff found in
[@GriffinSchneider's Emacs configs](https://github.com/GriffinSchneider/emacs-config).

## Installation

    $ cd ~/.emacs.d/vendor
    $ git clone https://github.com/Janfel/moonscript-mode.git

And add following to your .emacs file:

    (add-to-list 'load-path "~/.emacs.d/vendor/moonscript-mode")
    (require 'moonscript-mode)
    (require 'moonscriptrepl-mode)

## Usage

### With a REPL

If you load up a moonscript REPL (see https://github.com/leafo/moonscript/wiki/Moonscriptrepl) you can 
then hit:

<key>M</key>-<key>X</key> `moonscriptrepl-mode`

to activate.

Improvements and more docs will come as we need them.
