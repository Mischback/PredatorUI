--[[
  Define the settings for the layout.

  Settings range from (very static) layout-specific things like the definition
  of textures to (more or less) dynamic settings, which might be changed on a
  per-character base.

  TODO: Implement/setup SavedVariables!
]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...

local settings = {}

-- Get access to shared media.
--
-- Predator-related shared media is provided in a dedicated addon.
local LSM = LibStub("LibSharedMedia-3.0")

if LSM == nil then
    return
end

-- ==============
-- LOCALIZE STUFF
-- ==============
local BACKGROUND = LSM.MediaType.BACKGROUND
local BORDER = LSM.MediaType.BORDER
local FONT = LSM.MediaType.FONT
local STATUSBAR = LSM.MediaType.STATUSBAR


-- ================
-- OVERALL SETTINGS
-- ================
settings.general = {
    ["borderWidth"] = 10,
    ["STATUS_OFFLINE"] = "offline",
    ["STATUS_DEAD"] = "dead",
}


-- ======
-- COLORS
-- ======
settings.colors = {
    ["borderDefault"] = { 0.5, 0.5, 0.5, 1 },
    ["hpBarFg"] = { 0.2, 0.2, 0.2, 1 },
    ["hpBarBg"] = { 0.3, 0.05, 0.05, 1 },
    ["hpMyHeal"] = { 0.4, 1, 0.4, 1 },
    ["hpHeal"] = { 0.4, 1, 0.4, 1 },
    ["castbarGeneric"] = { 0.86, 0.5, 0, 1 },
    ["hpValue"] = "DDDDDD",
    ["hpDeficit"] = "CC2222",
    ["name"] = "DDDDDD",
    ["glossIntensity"] = 0.7,
}

-- ========
-- TEXTURES
-- ========
settings.textures = {
    ["bar"] = LSM:Fetch(STATUSBAR, "PredatorStatusbar", false),
    ["bar2"] = LSM:Fetch(STATUSBAR, "PredatorElvBar", false),
    ["border"] = LSM:Fetch(BORDER, "PredatorBorder", false),
    ["solid"] = LSM:Fetch(BACKGROUND, "PredatorSolid", false),
    ["gloss"] = LSM:Fetch(BACKGROUND, "PredatorGloss", false),
    ["overlay"] = LSM:Fetch(BACKGROUND, "PredatorOverlay", false),
}

-- =====
-- FONTS
-- =====
settings.fonts = {
    ["hp"] = LSM:Fetch(FONT, "SharpDistress", false),
    ["details"] = LSM:Fetch(FONT, "MonaSans SemiCond SemiBold", false)
}


settings.createDefaults = function()
    local config = {
        ["player"] = {
            ["position"] = {"RIGHT", UIParent, "CENTER", -75, -250},
        },
        ["pet"] = {
            ["position"] = {"RIGHT", "PredatorUF_player", "LEFT", -20, 0},
        },
        ["playerCastbar"] = {
            ["useThis"] = true,
            ["mode"] = "simple",
            ["position"] = {"CENTER", UIParent, "CENTER", 0, -150},
        },
        ["target"] = {
            ["position"] = {"LEFT", UIParent, "CENTER", 75, -250},
        },
        ["targettarget"] = {
            ["position"] = {"LEFT", "PredatorUF_target", "RIGHT", 20, 0},
        },
        ["focus"] = {
            ["position"] = {"BOTTOMLEFT", "PredatorUF_targettarget", "TOPLEFT", 0, 100},
        },
    }

    return config
end

-- Attach to the addon's namespace
ns.settings = settings
