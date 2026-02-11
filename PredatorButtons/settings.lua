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


-- These are static settings, primarily lookups/constants.
settings.static = {
    ["BarName"] = {
        ["ActionBar"] = "PBActionBar1",
        ["ActionBar2"] = "PBActionBar2",
        ["ActionBar3"] = "PBActionBar3",
        ["ActionBar4"] = "PBActionBar4",
        ["ActionBar5"] = "PBActionBar5",
        ["ActionBar6"] = "PBActionBar6",
        ["ActionBar7"] = "PBActionBar7",
        ["ActionBar8"] = "PBActionBar8",
        ["StanceBar"] = "PBStanceBar",
        ["PetActionBar"] = "PBPetBar",
    },
    ["NumButtons"] = {
        ["ActionBar"] = NUM_ACTIONBAR_BUTTONS,
        ["ActionBar2"] = NUM_MULTIBAR_BUTTONS,
        ["ActionBar3"] = NUM_MULTIBAR_BUTTONS,
        ["ActionBar4"] = NUM_MULTIBAR_BUTTONS,
        ["ActionBar5"] = NUM_MULTIBAR_BUTTONS,
        ["ActionBar6"] = NUM_MULTIBAR_BUTTONS,
        ["ActionBar7"] = NUM_MULTIBAR_BUTTONS,
        ["ActionBar8"] = NUM_MULTIBAR_BUTTONS,
        ["StanceBar"] = 10,
        ["PetActionBar"] = 10,
    },
    ["BlizzardBarName"] = {
        ["ActionBar"] = "ActionButton",
        ["ActionBar2"] = "MultiBarBottomLeft",
        ["ActionBar3"] = "MultiBarBottomRight",
        ["ActionBar4"] = "MultiBarRight",
        ["ActionBar5"] = "MultiBarLeft",
        ["ActionBar6"] = "MultiBar5",
        ["ActionBar7"] = "MultiBar6",
        ["ActionBar8"] = "MultiBar7",
        ["StanceBar"] = "StanceBar",
        ["PetActionBar"] = "PetActionBar",
    },
    ["ButtonPrefix"] = {
        ["ActionBar"] = "ActionButton",
        ["ActionBar2"] = "MultiBarBottomLeftButton",
        ["ActionBar3"] = "MultiBarBottomRightButton",
        ["ActionBar4"] = "MultiBarRightButton",
        ["ActionBar5"] = "MultiBarLeftButton",
        ["ActionBar6"] = "MultiBar5Button",
        ["ActionBar7"] = "MultiBar6Button",
        ["ActionBar8"] = "MultiBar7Button",
        ["StanceBar"] = "StanceButton",
        ["PetActionBar"] = "PetActionButton",
    },
    -- FIXME: I don't think this is correct!
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

    bars["ActionBar3"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            90,
        },
    }

    bars["ActionBar4"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            135,
        },
    }

    bars["ActionBar5"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            180,
        },
    }

    bars["ActionBar6"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            225,
        },
    }

    bars["ActionBar7"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            270,
        },
    }

    bars["ActionBar8"] = {
        ["buttons"] = 12,
        ["columns"] = 12,
        ["sizeX"] = 36,
        ["sizeY"] = 36,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            315,
        },
    }

    bars["StanceBar"] = {
        ["buttons"] = 10,
        ["columns"] = 10,
        ["sizeX"] = 30,
        ["sizeY"] = 30,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            360,
        },
    }

    bars["PetActionBar"] = {
        ["buttons"] = 10,
        ["columns"] = 10,
        ["sizeX"] = 30,
        ["sizeY"] = 30,
        ["padding"] = 3,
        ["position"] = {
            "LEFT",
            10,
            405,
        },
    }

    return bars
end


ns.settings = settings
