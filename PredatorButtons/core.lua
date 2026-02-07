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
end)
