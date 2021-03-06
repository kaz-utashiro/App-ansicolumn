[![Build Status](https://travis-ci.com/kaz-utashiro/App-ansicolumn.svg?branch=master)](https://travis-ci.com/kaz-utashiro/App-ansicolumn)
# NAME

ansicolumn - ANSI terminal sequence aware column command

# VERSION

Version 1.05

# SYNOPSIS

ansicolumn \[options\] \[file ...\]

# DESCRIPTION

**ansicolumn** is a [column(1)](http://man.he.net/man1/column) command clone which can handle ANSI
terminal sequences.  It supports traditional options and some of Linux
extended, and other original options.  Empty lines are **not** ignored,
though.

## COMPATIBLE OPTIONS

The column utility formats its input into multiple columns.  Rows are
filled before columns.  Input is taken from _file_ operands, or, by
default, from the standard input.

- **-c**#, **--output-width**=#

    Output is formatted for a display columns wide.

- **-s**#, **--separator**=#

    Specify a set of characters to be used to delimit columns for the
    \-t option.

- **-t**, **--table**

    Determine the number of columns the input contains and create a
    table.  Columns are delimited with whitespace, by default, or
    with the characters supplied using the -s option.  Useful for
    pretty-printing displays.

- **-x**, **--fillrows**

    Fill columns before filling rows.

- **-o**#, **--output-separator**=#

    When used **--table** or **-t** option, each columns are joined by two
    space characters (' ') by default.  This option will change it.

- **-R**_columns_, **--table-right**=_columns_

    Right align text in these columns.
    Support only numbers.

## EXTENDED OPTION

- **-P**\[_#_\], **--page**\[=_#_\]

    Page mode.  Set these options.

        --height=[ terminal height - 1 ]
        --linestyle=wrap
        --border
        --fillup

    If optional number is given, it is used as a page height unless option
    **--height** exists.

- **-D**, **--document**

    Document mode.  Set these options.

        --fullwidth
        --linebreak=all
        --linestyle=wrap
        --boundary=word
        --no-white-space
        --no-isolation

    Next command display DOCX text in 3-up format using
    [App::optex::textconv](https://metacpan.org/pod/App::optex::textconv).

        optex -Mtextconv ansicolumn -DPC3 foo.docx | less

- **-C**#, **--pane**=#

    Output is formatted in the specified number of panes.  Setting number
    of panes implies **--fullwidth** option enabled.

- **-S**#, **--pane-width**=#, **--pw**=#

    Specify pane width.  This includes border spaces.

- **-F**, **--fullwidth**

    Use full width of the terminal.  Each panes are expanded to fill
    terminal width, unless **--pane-width** is specified.

- **--linestyle**=_none_|_truncate_|_wrap_|_wordwrap_, **--ls**=_..._

    Set the style of treatment for longer lines.
    Default is _none_.

    **--linestyle=wordrap** is equivalent to **--linestyle=wrap**
    **--boundary=word**.

- **--boundary**=_word_

    Set text wrap boundary.  If this option set to **word**, text is
    wrapped at word boundary.  Option **--document** set this automatically.
    Use something like \`--boundary=none' to disable it.

- **--linebreak**=_none|all|runin|runout_, **--lb**=...

    Set the linebreak mode.

- **--runin**=#, **--runout**=#

    Set the number of runin/runout column.
    Default is both 2.

- **--**\[**no-**\]**pagebreak**

    Move to next pane when form feed character found.
    Default true.

- **--border**\[=_style_\]

    Print border.  Enabled by **--page** option automatically.  If the
    optional _style_ is given, it is used as a border style and precedes
    to **--border-style** option.  Use **--border=none** to disable it.

    Border style is specified by **--border-style** option.

- **--border-style**=_style_, **--bs**=...

    Set the border style.  Current default style is **vbar**, which is
    light vertical line filling the page height.

    Sample styles:
    none,
    vbar, fence,
    line, heavy-line,
    ascii-frame, ascii-box,
    box, frame, page-frame,
    shadow, shadow-box,
    comb, rake, mesh,
    dumbbell, heavy-dumbbell,
    ribbon, round-ribbon, double-ribbon, double-double-ribbon, heavy-ribbon

    These are experimental and subject to change, and this document is not
    always up-to-date.  See \`perldoc -m App::ansicolumn::Border\` for
    actual data.

    You can define your own style in module or startup file.  Put next
    lines in your `$HOME/.ansicolumnrc` file, for example.

        option default --border-style myheart
        __PERL__
        App::ansicolumn::Border->add_style(
            myheart  => {
            left   => [ "\N{WHITE HEART SUIT} ", "\N{BLACK HEART SUIT} " ],
            center => [ "\N{WHITE HEART SUIT} ", "\N{BLACK HEART SUIT} " ],
            right  => [ "\N{WHITE HEART SUIT}" , "\N{BLACK HEART SUIT}"  ],
        },
        );

- **--height**=#

    Set page height and page mode on.

- **--**\[**no-**\]**ignore-space**, **--**\[**no-**\]**is**

    When used **-t** option, leading spaces are ignored by default.  Use
    **--no-ignore-space** option to disable it.

- **--**\[**no-**\]**insert-space**
- **--**\[**no-**\]**paragraph**

    Insert empty line between every successive non-empty lines.

- **--**\[**no-**\]**white-space**

    Allow white spaces at the top of each panes, or clean them up.
    Default true.  Negated by **--document** option.

- **--**\[**no-**\]**isolation**

    Allow the first line of a paragraph (continuous non-space lines) is
    placed at the bottom of a pane.  Default true.  If false, move it to
    the top of next pane.  Negated by **--document** option.

- **--fillup**\[=_pane|page|none_\]

    Fill up final pane or page by empty lines.  Parameter is optional and
    considered as 'pane' by default.  Set by **--page** option
    automatically.  Use **--fillup=none** if you want to explicitly disable
    it.

- **--tabstop**=#

    Set tab width.

- **--column-unit**=#

    Each columns are placed at unit of 8 by default.  This option changes
    the number of unit.

- **--ambiguous**=_width\_spec_

    Specifies how to treat Unicode ambiguous width characters.  Take a
    value of 'narrow' or 'wide.  Default is 'narrow'.

# STARTUP

This command is implemented with [Getopt::EX](https://metacpan.org/pod/Getopt::EX) module.  So

    ~/.ansicolumnrc

file is read at start up.  If you want use **--no-white-space** always,
put this line in your `~/.ansicolumnrc`.

    option default --no-white-space

Also command can be extended by original modules with **-M**
option. See \`perldoc Getopt::EX\` for detail.

# INSTALL

## CPANMINUS

    $ cpanm App::ansicolumn
    or
    $ curl -sL http://cpanmin.us | perl - App::ansicolumn

To get the latest code, use this:

    $ cpanm https://github.com/kaz-utashiro/App-ansicolumn.git

# EXAMPLES

[https://github.com/kaz-utashiro/App-ansicolumn/tree/master/images](https://github.com/kaz-utashiro/App-ansicolumn/tree/master/images)

# SEE ALSO

[column(1)](http://man.he.net/man1/column)

[App::ansicolumn](https://metacpan.org/pod/App::ansicolumn),
[https://github.com/kaz-utashiro/App-ansicolumn](https://github.com/kaz-utashiro/App-ansicolumn)

[Text::ANSI::Printf](https://metacpan.org/pod/Text::ANSI::Printf),
[https://github.com/kaz-utashiro/Text-ANSI-Printf](https://github.com/kaz-utashiro/Text-ANSI-Printf)

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright 2020 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
