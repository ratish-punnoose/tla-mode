
# Table of Contents

1.  [Installation](#org5f27ac5)
2.  [tla-mode Features](#orgc719d6f)
    1.  [Syntax highlighting](#org11889ca)
    2.  [Auto keyword capitalization](#orgec72cb1)
    3.  [Simple code-indentation](#org2fa4cea)
    4.  [Pretty symbols](#orga052b52)
    5.  [Auto template insertion](#org5fb0312)


<a id="org5f27ac5"></a>

# Installation

1.  Place the tla-mode.el in the load-path for emacs.  Reasonable places may be:
    1.  /usr/share/emacs/site-lisp (usually in the load-path)
    2.  .emacs.d (if it is in the load-path).
2.  Add to emacs initialization.
    1.  Simple method in .emacs or .emacs.d/init.el

	    (require 'tla-mode)
    2.  With use-package

	    (use-package tla-mode  :mode "\\.tla$")


<a id="orgc719d6f"></a>

# tla-mode Features

tla-mode for emacs provides a major mode for TLA+


<a id="org11889ca"></a>

## Syntax highlighting

Syntax for TLA+ is highlighted.  PlusCal syntax is not highlighted.


<a id="orgec72cb1"></a>

## Auto keyword capitalization

Keywords can be typed lower case.  They are recognized and
converted to upper-case automatically.


<a id="org2fa4cea"></a>

## Simple code-indentation

Code can be indented when hitting the Tab key. Here are cases
where this functionality works.

1.  Hitting tab at the beginning of a line cycles the indentation
    through the *\\\\ and
    * symbols found on the previous line.
2.  Hitting tab after typing  a word at the beginning of a line
    moves cursor below the last ==.
3.  Hitting tab after THEN or ELSE, indent the line to the last IF
    or ELSE.


<a id="orga052b52"></a>

## Pretty symbols

tla-mode supports pretty symbols in conjunction with the
prettify-symbols-mode.

-   tla-mode is smart enough to check if a
    symbol rendering is available by the font in use and it only
    prettifies symbols for which a rendering is available.
-   When symbols are used, tla-mode adds extra spaces to symbols to
    ensure that they have the same width as the character sequence
    they replace.

Note the following:

1.  TLA+ is indentation sensitive. So it is useful to use a
    mono-spaced font.
2.  Monospaced coding fonts have only a small number of the symbols
    that TLA+ actually supports.
3.  It is possible to use a fallback font. i.e. a fallback font is
    used for a symbol if the primary font does not have a rendering
    for the symbol.
4.  However, even if a fallback font is used, the width of characters
    with that font will be different from the primary font causing
    inconsistent spacing.

To make this work correctly, do the following:

1.  Find a fallback font that supports symbols and has the same
    width as the primary font. Luckily, a good soul has a solution
    for this.   <https://github.com/cpitclaudel/monospacifier> has a tool to
    adjust a variable width font to match the width of a reference
    font.  The same site also has ready to download symbol fonts
    that are already fixed up to match some commonly used coding fonts.
2.  Symbola is a font with good symbol support.  To add it as a
    fallback font, do something like the following.

	(dolist (ft (fontset-list))
	  (set-fontset-font ft 'unicode (font-spec :name "Consolas"))
	  (set-fontset-font ft 'unicode (font-spec :name "Symbola monospacified for Consolas") nil 'append))
3.  In tla-mode,  enable prettify-symbols-mode  (M-x
    prettify-symbols-mode).  To do this always, add a hook

	(add-hook 'tla-mode 'prettify-symbols-mode)


<a id="org5fb0312"></a>

## Auto template insertion

When opening an empty .tla file, the Module header and footer is automatically added.
This can be prevented by setting tla-template-by-default to nil.

