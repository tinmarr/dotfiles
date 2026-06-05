-- ~/.config/hypr/lid.lua
-- Lid switch handler.
--
-- On lid close:
--   * If an external monitor is connected, disable eDP-1 (clamshell mode).
--   * Otherwise, suspend the system.
--
-- On lid open:
--   * Re-enable eDP-1 with the default laptop config.
--   * Force DPMS on to wake the display after suspend.

-- Default laptop monitor spec. Must match hyprland.lua's initial config.
---@type HL.MonitorSpec
local LAPTOP_MONITOR = {
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = 1.33,
    icc = os.getenv("HOME") .. "/.local/share/icc/framework13.icm",
}

---@return boolean true if at least one non-eDP-1 monitor is currently active
local function has_external_monitor()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= "eDP-1" then
            return true
        end
    end
    return false
end

local function close()
    if has_external_monitor() then
        hl.monitor({ output = "eDP-1", disabled = true })
    else
        hl.exec_cmd("systemctl suspend")
    end
end

local function open()
    -- Reload config so Hyprland re-detects outputs. This is the only
    -- way to re-add eDP-1 after a suspend where the kernel dropped its
    -- HPD assertion (known Framework 13 AMD + s2idle issue).
    hl.exec_cmd("hyprctl reload")
    -- The 500ms timer must complete before reload, then wait a bit more
    -- for the reload to finish applying the monitor rule.
    hl.timer(function()
        hl.monitor(LAPTOP_MONITOR)
        hl.dispatch(hl.dsp.dpms({ action = "enable" }))
    end, { timeout = 500, type = "oneshot" })
end

return {
    LAPTOP_MONITOR = LAPTOP_MONITOR,
    close = close,
    open = open,
}
