-- ########################
-- ## KEYBINDS           ##
-- ########################

local term = "kitty"
local editor = "nvim"
local browser = "zen-browser"
local incogbrowser = "zen-browser --private-window"
local launcher = "quickshell -p ~/.config/quickshell/launcher ipc call launcher toggle"
local sysmon = "kitty -e btop"
local music = "kitty -e cmus"

local yt = "https://youtube.com"
local perplexity = "https://perplexity.ai"
local chatgpt = "https://chat.openai.com"
local reddit = "https://reddit.com"
local ghprofile = "https://github.com/Cybersnake223?tab=repositories"
local wallhaven = "https://wallhaven.cc"

-- F-keys
hl.bind("F1", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"))
hl.bind("F2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 10%-"))
hl.bind("F3", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 10%+"))
hl.bind("F4", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"))
hl.bind("F11", hl.dsp.exec_cmd("brightnessctl -q s 10%-"))
hl.bind("F12", hl.dsp.exec_cmd("brightnessctl -q s +10%"))
hl.bind("F7", hl.dsp.exec_cmd("rfkill-toggle wlan"))
hl.bind("F9", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/lockscreen ipc call lockscreen toggle"))
hl.bind("Print", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call screenshot toggle"))

-- Terminal & Core Apps
hl.bind("ALT + Return", hl.dsp.exec_cmd(term))
hl.bind("ALT + Q", hl.dsp.window.close())
hl.bind("ALT + R", hl.dsp.exec_cmd(term .. " -e yazi"))
hl.bind("ALT + M", hl.dsp.exec_cmd(music))
hl.bind("ALT + N", hl.dsp.exec_cmd(term .. " -e " .. editor))
hl.bind("ALT + H", hl.dsp.exec_cmd(sysmon))
hl.bind("ALT + S", hl.dsp.exec_cmd("localsend"))
hl.bind("ALT + D", hl.dsp.exec_cmd(launcher))
hl.bind("ALT + E", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call emoji toggle"))
hl.bind("ALT + X", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call powermenu toggle"))
hl.bind("ALT + B", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call bluetooth toggle"))
hl.bind("ALT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("ALT + T", hl.dsp.exec_cmd(term .. " -e aerc"))
hl.bind("ALT + K", hl.dsp.exec_cmd("wkill"))
hl.bind("ALT + W", hl.dsp.exec_cmd("changewall"))
hl.bind("ALT + L", hl.dsp.exec_cmd(term .. " --title airpods-tui -e airpods-tui"))
hl.bind("ALT + Y", hl.dsp.exec_cmd("ytdla"))
hl.bind("ALT + C", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call notifications dismissAll"))
hl.bind("ALT + V", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call clipboard toggle"))

hl.bind("ALT + SHIFT + V", hl.dsp.exec_cmd("watchvid"))
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd("qs -p ~/.config/quickshell/hyprlens/UniversalSnip.qml -n"))
hl.bind("ALT + SHIFT + K", hl.dsp.exec_cmd("ccleaner -y"))
hl.bind("ALT + SHIFT + T", hl.dsp.exec_cmd("nautilus"))
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd("aria2cd"))
hl.bind("ALT + SHIFT + C", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call scriptedit toggle"))
hl.bind("ALT + SHIFT + E", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call editconf toggle"))
hl.bind("ALT + SHIFT + N", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/launcher ipc call wifi toggle"))
hl.bind("ALT + SHIFT + P", hl.dsp.exec_cmd(term .. " --title wiremix -e wiremix"))

-- Web Apps
hl.bind("ALT + SHIFT + B", hl.dsp.exec_cmd(browser))
hl.bind("ALT + SHIFT + I", hl.dsp.exec_cmd(incogbrowser))
hl.bind("ALT + G", hl.dsp.exec_cmd(browser .. " " .. ghprofile))
hl.bind("ALT + SHIFT + Y", hl.dsp.exec_cmd(browser .. " " .. yt))
hl.bind("ALT + SHIFT + G", hl.dsp.exec_cmd(browser .. " " .. perplexity))
hl.bind("ALT + SHIFT + W", hl.dsp.exec_cmd(browser .. " " .. wallhaven))
hl.bind("ALT + SHIFT + O", hl.dsp.exec_cmd(browser .. " " .. chatgpt))
hl.bind("ALT + SHIFT + R", hl.dsp.exec_cmd(browser .. " " .. reddit))

-- Layout Controls
hl.bind("ALT + P", hl.dsp.window.float({ action = "toggle" }))

-- Window Focus
hl.bind("ALT + left", hl.dsp.focus({ direction = "l" }))
hl.bind("ALT + right", hl.dsp.focus({ direction = "r" }))
hl.bind("ALT + up", hl.dsp.focus({ direction = "u" }))
hl.bind("ALT + down", hl.dsp.focus({ direction = "d" }))

-- Swap Windows
hl.bind("ALT + SHIFT + left", hl.dsp.window.swap({ direction = "l" }))
hl.bind("ALT + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind("ALT + SHIFT + up", hl.dsp.window.swap({ direction = "u" }))
hl.bind("ALT + SHIFT + down", hl.dsp.window.swap({ direction = "d" }))

-- Resize
hl.bind("ALT + CTRL + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind("ALT + CTRL + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind("ALT + CTRL + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind("ALT + CTRL + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))

-- Mouse: move + resize
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Special Workspace (scratchpad)
hl.bind("ALT + grave", hl.dsp.workspace.toggle_special("magic"))
hl.bind("ALT + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic" }))

-- Switch Workspaces
for i = 1, 9 do
	hl.bind("ALT + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind("ALT + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind("ALT + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("ALT + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

-- Scroll through workspaces
hl.bind("ALT + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
