local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local mic = wibox.widget({
	text = "",
	font = "JetBrainsMono Nerd Font 14",
	align = "center",
	valign = "center",
	widget = wibox.widget.textbox,
})

local function update()
	awful.spawn.easy_async_with_shell("wpctl get-volume @DEFAULT_AUDIO_SOURCE@", function(out)
		if out and out:find("MUTED", 1, true) then
			mic.markup =
			"<span font_desc='JetBrainsMono Nerd Font 14' foreground='#ff5555' weight='bold'> muted</span>"
		else
			mic.markup = "<span font_desc='JetBrainsMono Nerd Font 14' foreground='#f8f8f2'> on</span>"
		end
	end)
end

-- Polling timer (this is REQUIRED)
gears.timer({
	timeout = 0.1,
	autostart = true,
	call_now = true,
	callback = update,
})

-- Click to toggle
-- Make sure mic-toggle.sh is on PATH
mic:buttons(gears.table.join(awful.button({}, 1, function()
	awful.spawn("mic-toggle.sh", false)
end)))

return mic
