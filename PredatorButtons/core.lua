--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local ADDON_NAME, ns = ...



-- ==============
-- LOCALIZE STUFF
-- ==============
-- Grab other modules of *this* addon
local settings = ns.settings
local util = ns.util
local core = {}


local ctrl = CreateFrame("FRAME", nil, UIParent)
ctrl:RegisterEvent("ADDON_LOADED")
ctrl:SetScript("OnEvent", function(self, event, addon)
    if addon ~= ADDON_NAME then return end

    if not PredatorButtonsSettings then
        print("Creating default settings for ", ADDON_NAME)
        PredatorButtonsSettings = settings.createDefaults()
    end

    -- grab the existing ActionBars
    local ab2 = util.createBar("ActionBar2")


    -- at this point everything should be done!
    print(ADDON_NAME, "loaded...")
end)
