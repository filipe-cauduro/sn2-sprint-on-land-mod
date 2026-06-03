local is_hook_registered = false
local hook_pre_id = nil
local hook_post_id = nil
local last_footstep_time = 0
local default_min_speed = nil

-- State cached for the hook to use natively
local hook_state = {
    enabled = false,
    is_sprinting = false,
    pawn = nil
}

local function reset(pawn)
    hook_state.pawn = nil
    if pawn and pawn:IsValid() and default_min_speed then
        pcall(function()
            if pawn.MinSpeedForFootstepSounds >= 99999.0 then
                pawn.MinSpeedForFootstepSounds = default_min_speed
            end
        end)
    end
end

local function update(pawn, ModState, is_sprinting, debug_print)
    -- Update cached state for hook
    hook_state.enabled = ModState.enabled
    hook_state.is_sprinting = is_sprinting
    hook_state.pawn = pawn

    -- Manage Hook Registration
    if ModState.enabled then
        if not is_hook_registered then
            local hook_path = "/Game/GameplayCueNotifies/Player/GC_PlayerFootstep.GC_PlayerFootstep_C:OnBurst"
            local ufunc = nil
            pcall(function() ufunc = StaticFindObject(hook_path) end)
            if ufunc and ufunc:IsValid() then
                local ok, pre, post = pcall(function()
                    return RegisterHook(hook_path, function(self)
                        last_footstep_time = os.clock()
                        if hook_state.enabled and hook_state.is_sprinting and hook_state.pawn and hook_state.pawn:IsValid() then
                            pcall(function() hook_state.pawn.MinSpeedForFootstepSounds = 99999.0 end)
                        end
                    end)
                end)
                if ok then
                    is_hook_registered = true
                    hook_pre_id = pre
                    hook_post_id = post
                    debug_print("[SprintOnLandMod] Hooked GC_PlayerFootstep:OnBurst successfully!")
                else
                    is_hook_registered = true
                    debug_print("[SprintOnLandMod] Failed to hook GC_PlayerFootstep:OnBurst: " .. tostring(pre))
                end
            end
        end
    else
        if is_hook_registered and hook_pre_id and hook_post_id then
            local hook_path = "/Game/GameplayCueNotifies/Player/GC_PlayerFootstep.GC_PlayerFootstep_C:OnBurst"
            pcall(function()
                UnregisterHook(hook_path, hook_pre_id, hook_post_id)
            end)
            debug_print("[SprintOnLandMod] Unregistered GC_PlayerFootstep:OnBurst because mod was disabled.")
            is_hook_registered = false
            hook_pre_id = nil
            hook_post_id = nil
        end
    end

    -- Capture default speed
    if default_min_speed == nil then
        local ds_ok, ds_val = pcall(function() return pawn.MinSpeedForFootstepSounds end)
        if ds_ok and ds_val and ds_val < 99999.0 then
            default_min_speed = ds_val
        else
            default_min_speed = 0.0
        end
    end

    -- Dynamic Footstep Rate Limiter
    if is_sprinting then
        local target_interval = (ModState.sprint_footstep_interval_ms or 350) / 1000.0
        local current_time = os.clock()
        
        if (current_time - last_footstep_time) >= target_interval then
            pcall(function() pawn.MinSpeedForFootstepSounds = default_min_speed end)
        else
            pcall(function() pawn.MinSpeedForFootstepSounds = 99999.0 end)
        end
    else
        pcall(function()
            if pawn.MinSpeedForFootstepSounds >= 99999.0 then
                pawn.MinSpeedForFootstepSounds = default_min_speed
            end
        end)
    end
end

return {
    reset = reset,
    update = update
}
