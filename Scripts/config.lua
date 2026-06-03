local config = {
    -- If false, the mod is completely disabled.
    enabled = true,

    -- The multiplier applied to the character's base walk speed when sprinting
    sprint_multiplier = 2,

    -- If true, enables debug logging (e.g., when sprinting starts/stops or when keys are toggled).
    -- If false, only initialization logs are printed.
    debug = false,

    -- The minimum time (in milliseconds) between footstep sounds while sprinting.
    -- The game's default walking pacing plays a footstep approximately every 500-600ms.
    -- Because sprinting plays the running animation, the game tries to play footsteps too fast.
    -- Set this between 300 to 500 to throttle the sounds to a comfortable running pace. 
    -- 350-450ms is highly recommended for a natural feel.
    sprint_footstep_interval_ms = 350,

    -- If true, pressing the sprint key will toggle sprinting on/off.
    -- If false, sprinting is only active while the sprint key is held down.
    sprint_mode_toggle = false,

    -- The keys used to trigger sprinting.
    -- These correspond to standard Unreal Engine FKey names (e.g., "LeftShift", "RightShift", "LeftControl")
    sprint_keys = {
        "LeftShift",
        "RightShift"
    },

    -- The interval in milliseconds for the update loop (frequency of key state checking)
    -- Lower values make key press detection more responsive, higher values use less CPU
    update_interval_ms = 50
}

return config
