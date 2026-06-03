local MOD_VERSION = "1.0.0"
print("[SprintOnLandMod] Initializing mod v" .. MOD_VERSION .. "...")

local mod_dir = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])")
if mod_dir then
    if not package.path:find(mod_dir, 1, true) then
        package.path = package.path .. ";" .. mod_dir .. "?.lua"
    end
end

local UEHelpers = require("UEHelpers")

-- Force reload submodules to prevent caching on hot-reload (Ctrl+R)
package.loaded["state"] = nil
package.loaded["input"] = nil
package.loaded["movement"] = nil
package.loaded["audio"] = nil

local state = require("state")
state.init(MOD_VERSION)

local input = require("input")
local movement = require("movement")
local audio = require("audio")

local cached_player_pawn = nil
local cached_movement_component = nil

LoopAsync(state.get().update_interval_ms, function()
    local success, err = pcall(function()
        state.update_integration()
        local ModState = state.get()
        local debug_print = state.debug_print

        local pc = UEHelpers.GetPlayerController()
        if not pc or not pc:IsValid() or not ModState.enabled then
            movement.reset(cached_movement_component)
            input.reset()
            audio.reset(cached_player_pawn)
            
            cached_player_pawn = nil
            cached_movement_component = nil
            return
        end

        local pawn = pc.Pawn
        if not pawn or not pawn:IsValid() then
            movement.reset(cached_movement_component)
            input.reset()
            audio.reset(cached_player_pawn)
            
            cached_player_pawn = nil
            cached_movement_component = nil
            return
        end

        local movement_component = pawn.CharacterMovement
        if not movement_component or not movement_component:IsValid() then
            input.reset()
            cached_player_pawn = nil
            cached_movement_component = nil
            return
        end

        cached_player_pawn = pawn
        cached_movement_component = movement_component

        local target_sprint_state = input.get_target_sprint_state(pc, movement_component, ModState, debug_print)
        movement.update(movement_component, target_sprint_state, ModState, debug_print)
        
        local is_sprinting = movement.get_is_sprinting()
        audio.update(pawn, ModState, is_sprinting, debug_print)
    end)

    if not success then
        state.debug_print("[SprintOnLandMod] Error in update loop: " .. tostring(err))
    end
end)

print("[SprintOnLandMod] Mod initialized successfully!")
