-- Configure widgets to show

-- Global config variables

battery = true
wifi = true

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}




-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys",          function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",           terminal .. " -e man awesome" },
    { "edit conf nvim",   editor_cmd .. " " .. awesome.conffile },
    { "edit conf vscode", "code" .. " " .. awesome.conffile },

}

local power_options_group = {
    { "lock_session", function() awful.spawn.with_shell("xlock") end },
    { "suspend",
        function()
            awful.spawn.with_shell(
                'systemctl suspend && xlock')
        end },
    { "reboot",       "reboot" },
    { "shutdown",     "poweroff" },
}

local awesome_power_options = {
    { "restart awesome", awesome.restart },
    { "quit awesome",    function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }


mymainmenu = awful.menu({
    items = { { "awesome", myawesomemenu,    beautiful.awesome_icon },
        { "open terminal", terminal },
        { "power options", power_options_group },
        { "awesome power", awesome_power_options },
        { "brave",         "brave" },
    }
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
-- mytextclock = wibox.widget.textclock()

-- Test my clock preference
mytextclock = wibox.widget.textclock(" %a %d %b %H:%M:%S", 1)
--- Personal Widgets

-- Calendar widget

local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
-- ...
-- Create a textclock widget
-- mytextclock = wibox.widget.textclock()
-- default
-- local cw = calendar_widget()
-- or customized
local cw = calendar_widget({
    theme = 'nord',
    placement = 'bottom_right',
    radius = 8,
})

mytextclock:connect_signal("button::press",
    function(_, _, _, button)
        if button == 1 then cw.toggle() end
    end)

-- Logout - Power button widget

local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")



--  Import volume.lua
require("volume")

-- Add network widgets
local net_widgets = require("net_widgets")

-- Add speed network widget
local net_speed_widget = require("awesome-wm-widgets.net-speed-widget.net-speed")


net_wireless = net_widgets.wireless()
net_internet = net_widgets.internet({ indent = 0, timeout = 5 })

net_wired = net_widgets.indicator({
    interfaces = { "wlp3s0", "enp2s0", "lo" }, -- manual set current used interface with iwconfig
    timeout    = 5
})


local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


function show_battery(battery)
    if battery then
        return
            batteryarc_widget({
                show_current_level = true,
                arc_thickness = 1,
            })
    end
end

function show_wifi(wifi)
    if wifi then
        return
            net_wireless,
            net_internet
    end
end

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        {             -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            --- Add custom logout button widget
            logout_menu_widget {
                font = 'Play 14',
                onlock = function() awful.spawn.with_shell('i3lock-fancy') end
            },
            -- Add custom battery icon
            show_battery(battery),


            -- Add custom wifi icon
            show_wifi(wifi),

            -- Add speed network widget
            net_speed_widget(),
            net_wired,
            mykeyboardlayout,
            wibox.widget.systray(),
            volume_widget, -- added line
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}




-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end)
-- comment the following lines to avoid mouse wheel from turning tags
-- awful.button({ }, 4, awful.tag.viewnext),
-- awful.button({ }, 5, awful.tag.viewprev)

))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ modkey, }, "`", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Ctrl" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),


    -- Personal keybindings

    awful.key({ modkey, }, "e",
        function() awful.spawn("thunar") end,
        { description = "Launch Thunar", group = "apps" }),

    awful.key({ modkey, "Shift" }, "w",
        function() awful.spawn("brave") end,
        { description = "Launch Brave", group = "apps" }),

    awful.key({ modkey, }, "b",
        function() awful.spawn("bitwarden-desktop") end,
        { description = "Launch Bitwarden", group = "apps" }),


    awful.key({ modkey, "Control", "Shift" }, "a",
        function() awful.spawn("code") end,
        { description = "Launch Vscode", group = "apps" }),

    awful.key({ modkey, "Control", "Shift" }, "l",
        function() awful.spawn.with_shell("xlock") end,
        { description = "Lock Screen", group = "client" }),


    -- Move current window to next tag or prev tag

    -- Ctrl+Alt+Shift+Left/Right: move client to prev/next tag
    awful.key({ modkey, "Control", "Shift" }, "Left",
        function()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
            local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
            awful.client.movetotag(tag)
        end,
        { description = "move client to previous tag", group = "layout" }),
    awful.key({ modkey, "Control", "Shift" }, "Right",
        function()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
            local tag = client.focus.screen.tags[(t.name % 9) + 1]
            awful.client.movetotag(tag)
        end,
        { description = "move client to next tag", group = "layout" }),


    -- Move current window along with screen to next tag or prev tag


    -- Win+Shift+Left/Right: move client to prev/next tag and switch to it

    awful.key({ modkey, "Shift" }, "Left",
        function()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
            local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
            awful.client.movetotag(tag)
            awful.tag.viewprev()
        end,
        { description = "move client to previous tag and switch to it", group = "layout" }),
    awful.key({ modkey, "Shift" }, "Right",
        function()
            -- get current tag
            local t = client.focus and client.focus.first_tag or nil
            if t == nil then
                return
            end
            -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
            local tag = client.focus.screen.tags[(t.name % 9) + 1]
            awful.client.movetotag(tag)
            awful.tag.viewnext()
        end,
        { description = "move client to next tag and switch to it", group = "layout" }),


    --- Rofi keybindings
    awful.key({ modkey }, "w", function()
        awful.spawn("rofi -show window")
    end),


    --- Volume keybindings

    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("amixer set Master 5%+")
    end),
    -- awful.spawn("volume up") end),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("amixer set Master 5%-")
    end),
    -- awful.spawn("volume down") end),
    awful.key({}, "XF86AudioMute", function()
        -- awful.spawn("volume mute") end),
        awful.spawn("amixer -D pulse set Master 1+ toggle")
    end),

    --- Volume keybindings without volume MediaKeys

    awful.key({ modkey, "Ctrl", "Shift" }, "=", function()
        awful.spawn("amixer set Master 5%+")
    end),
    -- awful.spawn("volume up") end),
    awful.key({ modkey, "Ctrl", "Shift" }, "-", function()
        awful.spawn("amixer set Master 5%-")
    end),
    -- awful.spawn("volume down") end),
    awful.key({ modkey, "Ctrl", "Shift" }, "0", function()
        awful.spawn("amixer -D pulse set Master 1+ toggle")
    end),
    -- awful.spawn("volume mute") end),

    --- MediaKeys keybindings without MediaKeys

    awful.key({ modkey, "Ctrl", "Shift" }, "[", function()
        awful.spawn("playerctl previous")
    end),

    awful.key({ modkey, "Ctrl", "Shift" }, "p", function()
        awful.spawn("playerctl play-pause")
    end),

    awful.key({ modkey, "Ctrl", "Shift" }, "]", function()
        awful.spawn("playerctl next")
    end),

    --- MediaKeys keybindings

    awful.key({}, "XF86AudioPlay", function()
        awful.spawn("playerctl play-pause")
    end),
    awful.key({}, "XF86AudioStop", function()
        awful.spawn("playerctl stop")
    end),
    awful.key({}, "XF86AudioNext", function()
        awful.spawn("playerctl next")
    end),
    awful.key({}, "XF86AudioPrev", function()
        awful.spawn("playerctl previous")
    end),


    -- Brightness

    -- awful.key({}, "XF86MonBrightnessDown", function()
    --     awful.util.spawn("xbacklight -dec 5")
    -- end),
    -- awful.key({}, "XF86MonBrightnessUp", function()
    --     awful.util.spawn("xbacklight -inc 5")
    -- end),

    -- New brightness

    -- Brightness Control with brightnessctl
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn("brightnessctl set +1000", false)
    end, { description = "increase brightness", group = "custom" }),
    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn("brightnessctl set 1000-", false)
    end, { description = "decrease brightness", group = "custom" }),


    -- Spotify keybindings
    -- set Music Media Key as spotify
    awful.key({}, "#179", function()
            awful.spawn("spotify")
        end,
        { description = "Launch Spotify", group = "apps" }),



    -- Screenshooter
    awful.key({}, "#107", function()
            awful.spawn("flameshot gui")
        end,
        { description = "Launch flameshot gui", group = "screenshot" }),

    -- Screenshooter
    awful.key({ "Shift", modkey }, "#107", function()
            awful.spawn.with_shell(
                "mkdir -p $HOME/Pictures/screenshots/ && flameshot screen -p $HOME/Pictures/screenshots/")
        end,
        { description = "Capture and save current screen", group = "screenshot" }),
    awful.key({ "Shift" }, "#107", function()
            awful.spawn.with_shell(
                "mkdir -p $HOME/Pictures/screenshots/ && flameshot full -p $HOME/Pictures/screenshots/")
        end,
        { description = "Capture and save full screen", group = "screenshot" }),
    awful.key({ modkey, "Ctrl", "Shift" }, "s", function()
            awful.spawn.with_shell("systemctl suspend && xlock")
        end,
        { description = "Suspend and lock session", group = "client" }),

    -- End of Personal keybindings

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" }),
    awful.key({ modkey }, "d", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" })
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "close", group = "client" }),

    -- Start personal edit

    awful.key({ modkey, }, "y", function(c) c.sticky = not c.sticky end,
        { description = "make window sticky", group = "client" }),


    -- Move windows in floating layout with win+alt+arrowkeys

    awful.key({ modkey, "Mod1" }, "Down", function(c) c:relative_move(0, 20, 0, 0) end),
    awful.key({ modkey, "Mod1" }, "Up", function(c) c:relative_move(0, -20, 0, 0) end),
    awful.key({ modkey, "Mod1" }, "Left", function(c) c:relative_move(-20, 0, 0, 0) end),
    awful.key({ modkey, "Mod1" }, "Right", function(c) c:relative_move(20, 0, 0, 0) end),


    -- Re-draw windows layout in floating layout
    awful.key({ modkey, "Mod1", "Shift" }, "Up", function(c) c:relative_move(-20, -20, 40, 40) end),
    awful.key({ modkey, "Mod1", "Shift" }, "Down", function(c) c:relative_move(20, 20, -40, -40) end),

    -- End of personal edit

    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end),
    -- Custom function to make close tab with Super + Middle Click
    awful.button({ modkey }, 2, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        c:kill()
    end)
)


-- Function to swap clients between the current tag and another specified tag
-- Win+Alt+number: swap current tag with tag number

-- Local function for swapping client
local function swap_clients_with_tag(other_tag)
    if not other_tag then
        return
    end

    local current_tag = awful.screen.focused().selected_tag
    if current_tag == other_tag then
        return -- Do nothing if the tags are the same
    end

    local clients_current = current_tag:clients()
    local clients_other = other_tag:clients()

    for _, c in ipairs(clients_current) do
        c:move_to_tag(other_tag)
    end

    for _, c in ipairs(clients_other) do
        c:move_to_tag(current_tag)
    end
end


-- Keybindings for modkey + Alt + number
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    swap_clients_with_tag(tag)
                end
            end,
            {description = "swap with tag #"..i, group = "tag"})
    )
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer" },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
--  }}}

-- Run this line to allow polkit agent to run on start
-- This allows graphicals interfaces to ask for authentication
awful.spawn.with_shell("exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")


-- Autorun apps

local function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end
    -- Use pgrep to find the process by name and only run the command if it doesn't exist
    awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

-- Now you can call run_once with the command for each application
run_once("volumeicon")
run_once("nm-applet")
run_once("xfce4-power-manager")
run_once("xfsettingsd --daemon")

-- Other autorun programs
local autorunApps = {
    "sh -c $HOME/dotfiles/scripts/wallpaper_changer_cron.sh",
    "sh -c $HOME/dotfiles/scripts/fix-scroll.sh",
}

for _, app in ipairs(autorunApps) do
    run_once(app)
end


-- Debug awesome getting nano as editor

--vart = os.execute('printenv > /tmp/hola')
-- naughty.notify({text=tostring((vart))})
-- naughty.notify({text=tostring((editor))})
