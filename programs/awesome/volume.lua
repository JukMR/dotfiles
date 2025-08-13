local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")

function update_volume(widget)
    local fd = io.popen("amixer sget Master")
    local status = fd:read("*all")
    fd:close()

    -- Try to get the volume level as a string (e.g., "75")
    local volume_str = string.match(status, "(%d?%d?%d)%%")

    if volume_str == nil then
        -- If no volume was found, display a placeholder and stop.
        widget:set_markup(" --% ")
        return -- Exit the function early to prevent a crash
    end

    -- If we are here, we have a valid volume string. Proceed with your logic.
    local volume_num = tonumber(volume_str)
    local volume = string.format("% 3d", volume_num)

    local mute_status = string.match(status, "%[(o[^%]]*)%]")

    if mute_status and string.find(mute_status, "on", 1, true) then
        -- For the volume numbers
        volume = volume .. "%"
    else
        -- For the mute button
        volume = volume .. "M"
    end
    widget:set_markup(volume)
end

mytimer = gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function() update_volume(volume_widget) end
}
