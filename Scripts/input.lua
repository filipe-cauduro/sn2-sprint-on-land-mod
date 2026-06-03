local UEHelpers = require("UEHelpers")

local was_key_pressed = false
local sprint_toggle_active = false

local function reset()
    was_key_pressed = false
    sprint_toggle_active = false
end

local function get_target_sprint_state(pc, movement_component, ModState, debug_print)
    local is_sprint_key_pressed = false
    for _, key_name in ipairs(ModState.sprint_keys) do
        local key_name_fname = UEHelpers.FindOrAddFName(key_name)
        local key = { KeyName = key_name_fname }
        
        local key_status_ok, is_down = pcall(function()
            return pc:IsInputKeyDown(key)
        end)
        
        if key_status_ok and is_down then
            is_sprint_key_pressed = true
            break
        end
    end

    local is_on_land = movement_component.MovementMode ~= 4
    local target_sprint_state = false

    if ModState.sprint_mode_toggle then
        local just_pressed = is_sprint_key_pressed and not was_key_pressed
        was_key_pressed = is_sprint_key_pressed

        if just_pressed and is_on_land then
            sprint_toggle_active = not sprint_toggle_active
            debug_print(string.format("[SprintOnLandMod] Sprint toggled: %s", tostring(sprint_toggle_active)))
        end

        if not is_on_land then sprint_toggle_active = false end
        target_sprint_state = sprint_toggle_active
    else
        target_sprint_state = is_sprint_key_pressed and is_on_land
    end

    return target_sprint_state
end

return {
    reset = reset,
    get_target_sprint_state = get_target_sprint_state
}
