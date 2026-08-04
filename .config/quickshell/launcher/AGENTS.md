# AGENTS.md

Quickshell overlay menus (app launcher, wifi, bluetooth, power, emoji, screenshot, edit config/script, watch-video) for Hyprland. No git repo, no tests, no linters. QML only.

## Run / verify

- Whole config: `quickshell -p ~/.config/quickshell/launcher/shell.qml` (installed as user service `quickshell.service`, `ExecStart=quickshell -c launcher`, started by `~/.config/hypr/modules/startup.lua`).
- A single menu in isolation (syntax/behavior check): `quickshell -p ~/.config/quickshell/launcher/AppLauncher.qml`. QML load errors print to stderr.
- Config name comes from the `launcher/` dir name + `shell.qml`; `quickshell -c launcher` works only if not already running (`-n` = no-duplicate).
- Theming depends on `~/.config/hypr/scripts/quickshell/qs_colors.json` existing (written by matugen) — menus fall back to Catppuccin Mocha if absent, so they render fine standalone.

## Architecture

- `shell.qml` is the entrypoint: it just instantiates each menu component. To add a menu, create `FooMenu.qml` and add an instance here; nothing is auto-discovered.
- Each menu = a full-screen transparent `PanelWindow` (layer overlay, `exclusiveZone: -1`, keyboardFocus OnDemand) containing one `MenuCard` (the shared centered card with dimming backdrop + open/close animations). New menus must use `MenuCard { }` and `import QtQuick.Layouts` (card content is a `ColumnLayout` via `default property alias content`).
- `MatugenColors { id: theme }` is instantiated *inside* each window (not imported as a module — there is no active `qmldir`). Access colors as `theme.text`, `theme.mauve`; when you need alpha, do `Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)` (`.r/.g/.b`), which is the pervasive idiom here.
- Theme colors are meant to be changed in MatugenColors.qml defaults, or by editing the matugen output file — not hardcoded in menus.

## IPC / wiring (two parallel mechanisms — keep both in sync)

1. Quickshell IPC: `IpcHandler { target: "launcher"; function toggle() {...} show() hide() }` → external call `quickshell -p ~/.config/quickshell/launcher/shell.qml ipc call launcher toggle`.
2. File IPC: `IpcWatcher { watchName: "launcher" }` runs `inotifywait` on `/tmp/qs_launcher`; external scripts just `echo toggle > /tmp/qs_launcher`.

Hyprland keybinds (`~/.config/hypr/modules/keybinds.lua`) use **file IPC only** (`echo toggle > /tmp/qs_<name>`). When adding a menu, add both the `IpcHandler` and an `IpcWatcher` with the same target/watchName, otherwise hotkeys won't find it.

## Data contracts

- `get_apps.sh` scans `/usr/share/applications`, `~/.local/share/applications`, flatpak exports; emits TSV `name\tExec\tIcon\tdesktop-id\tterminal`. `AppLauncher` parses that exact format (`parseAppsOutput`) — change both sides together.
- `AppLauncher.cleanExec` / `get_apps.sh sanitize_exec` both strip desktop-file `%f %u @@ --file-forwarding` tokens; keep both in sync.
- Terminal apps / editors launch through `kitty -e` (AppLauncher, EditConfig, ScriptEdit). `launch_wrapper.sh` is a debug wrapper that logs args to `/tmp/qs_launch_debug.log`.
- `EditConfig` has a hardcoded list of `~/.config/...` paths (label → path) in `Component.onCompleted`; add new files there.
- `ScriptEdit` lists `$SCRIPTS_DIR` or `$HOME/.local/bin/scripts` via `fd` (falls back to `find`).

## Gotchas

- `ClipboardMenu.qml` and `Notifications.qml` exist but are **not** instantiated in shell.qml (orphans). `LauncherWindow.qml.bak`, `qmldir.bak` are stale backups. Keybinds still write `/tmp/qs_clipboard` etc. — harmless.
- `MatugenColors.tertiaryContainer` is intentionally set to `c.teal` (copy of teal); don't "fix" it.
- Code style: 2-space indent, ripple-click animations on list delegates, `Behavior on` + `ColorAnimation` for hover/focus borders. Match existing delegate/animation patterns rather than inventing new ones.
- Interactive checks require a Wayland session; there is no headless verification. Test carefully — a QML parse error kills the whole config at next `quickshell` start.
