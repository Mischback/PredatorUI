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
ctrl:SetScript("OnEvent", function(self, event, addon)
    if addon ~= ADDON_NAME then return end


    -- at this point everything should be done!
    core.debugging("loaded successfully!")
end)
