
-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
local settings = {}


-- These are static settings, primarily lookups/constants.
settings.static = {
    ["design"] = {
        ["colorHex"] = "79c947",
        ["chatFontColor"] = { 0.47, 0.78, 0.28, 1},
        ["configFrameFontColor"] = {255, 255, 255, 1},
        ["configFrameBgColor"] = { 0.47, 0.78, 0.28, 0.75},
    },
    ["blizzard"] = {
        ["maxZoomLevel"] = nil,
    },
}


--[[ Create the addon's default Saved Variables

  TABLE createDefaults()
]]
settings.createDefaults = function()
    return {
        ["defaultZoomLevel"] = 0,
        ["autoResetZoom"] = true,
        ["resetZoomDelay"] = 3,
        ["size"] = 140,
        ["position"] = {
            "TOPRIGHT",
            -5,
            -5
        }
    }
end


ns.settings = settings
