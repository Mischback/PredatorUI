-- Provide addon-specific environment, don't work on global namespace
local ADDON_NAME, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
-- Grab other modules of *this* addon
local settings = ns.settings
local core = ns.core


local ctrl = CreateFrame("FRAME", nil, UIParent)
ctrl:RegisterEvent("ADDON_LOADED")
ctrl:RegisterEvent("PLAYER_ENTERING_WORLD")
ctrl:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" then
        if addon ~= ADDON_NAME then return end

        -- core.setupMinimap()

        -- at this point everything should be done!
        core.debugging("loaded successfully!")
        return
    end

    -- Actually apply our modifications!
    --
    -- ADDON_LOADED is too early for a full setup of the minimap, so we delay
    -- that until PLAYER_ENTERING_WORLD (main issue was the LFG tool).
    core.setupMinimap()

end)
