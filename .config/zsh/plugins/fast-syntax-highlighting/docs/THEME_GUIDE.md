# Theme Guide for F-Sy-H

`fast-theme` tool is used to select a theme. There are 6 shipped themes, they can be listed with `fast-theme -l`.
Themes are basic [INI files](https://github.com/z-shell/fast-syntax-highlighting/tree/main/themes) where each
key is a _style_.
Besides shipped themes, user can point this tool to any other theme, by simple `fast-theme ~/mytheme.ini`. To
obtain template to work on when creating own theme, issue `fast-theme --copy-shipped-theme {theme-name}`.

To alter just a few styles and not create a whole new theme, use **overlay**. What is overlay? It is in the same
format as full theme, but can have only a few styles defined, and these styles will overwrite styles in main-theme.
Example overlay file:

```ini
; overlay.ini
[base]
commandseparator = yellow,bold
comment          = 17

[command-point]
function       = green
command        = 180
```

File name `overlay.ini` is treated specially.

When specifing path, following short-hands can be used:

```ini
CONFIG:    = ~/.config/f-sy-h (respects $XDG_CONFIG_HOME env var)
CACHE:    = ~/.cache/zi/f-sy-h (respects $XDG_CACHE_HOME env var)
LOCAL:  = /usr/local/share/f-sy-h/
HOME:   = ~/.f-sy-h/
OPT:    = /opt/local/share/f-sy-h/
```

So for example, issue `fast-theme CONFIG:overlay` to load `~/.config/f-sy-h/overlay.ini` as overlay. The `.ini`
extension is optional.

## Secondary Theme

Each theme has key `secondary`, e.g. for theme `free`:

```ini
; free.ini
[base]
default          = none
unknown-token    = red,bold
; ...
; ...
; ...
secondary        = zdharma
```

Secondary theme (`zdharma` in the example) will be used for highlighting of argument for `eval`
and of `$( ... )` interior (i.e. of interior of command substitution). Basically, recursive
highlighting uses alternate theme to make the highlighted code distinct:

![sshot](https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/cmdsubst.png)

In the above screen-shot the interior of `$( ... )` uses different colors than the rest of the
code. Example for `eval`:

![image](https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/eval_cmp.png)

First line doesn't use recursive highlighting, highlights `eval` argument as regular string.
Second line switches theme to `zdharma` and does full recursive highlighting of eval argument.

## Custom Working Directory

Set `$FAST_WORK_DIR` before loading the plugin to have e.g. processed theme files (ready to
load, in Zsh format, not INI) kept under specified location. This is handy if e.g. you install
Fast-Syntax-Highlighting system-wide (e.g. from AUR on ArchLinux) and want to have per-user
theme setup.

You can use "~" in the path, e.g. `FAST_WORK_DIR=~/.f-sy-h` and also the `CONFIG:`, `CACHE:`, `LOCAL:`, `OPT:`,
etc. short-hands, so e.g. `FAST_WORK_DIR=CONFIG` or `FAST_WORK_DIR=CONFIG:` is allowed (in this case
it will be changed to `$HOME/.config/f-sy-h` by default by F-Sy-H loader).
