--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
local settings = {}


settings.static = {
    ["NumButtons"] = {
        ["ActionBar2"] = NUM_MULTIBAR_BUTTONS,
    },
    ["ButtonPrefix"] = {
        ["ActionBar2"] = "MultiBarBottomLeftButton",
    },
}


settings.createDefaults = function()
    local bars = {}

    bars["ActionBar2"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "CENTER",
            0,
            45,
        },
    }

    return bars
end


ns.settings = settings
