local config = require("config")

local ModState = {
    enabled = config.enabled ~= false,
    sprint_multiplier = config.sprint_multiplier or 1.6,
    sprint_mode_toggle = config.sprint_mode_toggle == true,
    sprint_keys = config.sprint_keys or { "LeftShift", "RightShift" },
    update_interval_ms = config.update_interval_ms or 50,
    is_debug = config.debug == true,
    sprint_footstep_interval_ms = config.sprint_footstep_interval_ms or (config.sprint_footstep_interval and config.sprint_footstep_interval * 1000) or 350
}

local function debug_print(msg)
    if ModState.is_debug then
        print(msg)
    end
end

-- SN2ModSettings Integration
package.loaded["sn2modsettings_integration"] = nil
local sn2msPollFunc = nil
local last_poll_time = 0

local function init(version)
    ModState.version = version
    pcall(function()
        sn2msPollFunc = require("sn2modsettings_integration")(ModState, debug_print)
    end)
end

local function update_integration()
    if sn2msPollFunc then
        local t = os.clock()
        if (t - last_poll_time) > 0.5 then
            pcall(sn2msPollFunc)
            last_poll_time = t
        end
    end
end

return {
    init = init,
    get = function() return ModState end,
    debug_print = debug_print,
    update_integration = update_integration
}
