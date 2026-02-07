--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
local settings = {}


-- Will be populated during addon loading process (see ``core.lua``)
settings["playerClass"] = nil


-- These are static settings, primarily lookups.
settings.static = {
    ["NumButtons"] = {
        ["ActionBar"] = NUM_ACTIONBAR_BUTTONS,
        ["ActionBar2"] = NUM_MULTIBAR_BUTTONS,
    },
    ["ButtonPrefix"] = {
        ["ActionBar"] = "ActionButton",
        ["ActionBar2"] = "MultiBarBottomLeftButton",
    },
    ['BlizzardActionBarPage'] = {
        ['DRUID'] = '[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;',
        ['WARRIOR'] = '[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;',
        ['PRIEST'] = '[bonusbar:1] 7;',
        ['ROGUE'] = '[bonusbar:1] 7; [form:3] 7;',
        ['WARLOCK'] = '[form:2] 7;',
        ['DEFAULT'] = '[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;',
    },
}


--[[ Create the addon's default Saved Variables

  TABLE createDefaults()
]]
settings.createDefaults = function()
    local bars = {}

    bars["ActionBar"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            0,
        },
    }

    bars["ActionBar2"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            45,
        },
    }

    return bars
end


ns.settings = settings
