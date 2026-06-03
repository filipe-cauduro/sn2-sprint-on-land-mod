local is_sprinting = false
local original_max_walk_speed = nil

local function reset(movement_component)
    if is_sprinting then
        if original_max_walk_speed and movement_component and movement_component:IsValid() then
            movement_component.MaxWalkSpeed = original_max_walk_speed
        end
        is_sprinting = false
        original_max_walk_speed = nil
    end
end

local function update(movement_component, target_sprint_state, ModState, debug_print)
    if target_sprint_state then
        if not is_sprinting then
            original_max_walk_speed = movement_component.MaxWalkSpeed
            local target_speed = original_max_walk_speed * ModState.sprint_multiplier
            movement_component.MaxWalkSpeed = target_speed
            is_sprinting = true
            debug_print(string.format("[SprintOnLandMod] Sprinting started. Walk speed: %.2f -> %.2f", original_max_walk_speed, target_speed))
        end
    else
        if is_sprinting then
            if original_max_walk_speed then
                movement_component.MaxWalkSpeed = original_max_walk_speed
                debug_print(string.format("[SprintOnLandMod] Sprinting stopped. Restored walk speed to: %.2f", original_max_walk_speed))
            end
            is_sprinting = false
            original_max_walk_speed = nil
        end
    end
end

local function get_is_sprinting()
    return is_sprinting
end

return {
    reset = reset,
    update = update,
    get_is_sprinting = get_is_sprinting
}
