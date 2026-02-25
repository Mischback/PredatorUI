std = "lua51"

quiet = 1  -- suppress output for clean files

ignore = {
    "212/msg",  -- unused argument ``msg``
    "212/self",  -- unused argument ``self``
    "212/event",  -- unused argument ``event``
    "212/frame",  -- unused argument ``frame``
    "431",  -- shadowing an upvalue
    "432",  -- shadowing an upvalue argument
    "631",  -- line is too long
}

-- keep this empty!
exclude_files = {}

globals = {
    -- our addons' global namespaces
    "PredatorButtons",
    "PredatorMinimap",
    "PredatorSharedMedia",

    -- Our addons' SavedVariables
    "PredatorButtonsSettings",
    "PredatorMinimapSettings",
    "PredatorUnitFramesSettings",

    -- Slash Commands
    "SLASH_PREDATORBUTTONS1",
    "SLASH_PREDATORBUTTONS2",
    "SLASH_PREDATORMINIMAP1",
    "SLASH_PREDATORMINIMAP2",

    -- Blizzard stuff we mess with
    "SlashCmdList",
}

read_globals = {
    -- stuff from other addons
    "LibStub",

    -- Blizzard UI functions
    "UIParent",
    "DEFAULT_CHAT_FRAME",
    "NUM_ACTIONBAR_BUTTONS",
    "NUM_MULTIBAR_BUTTONS",
    "MainMenuBar_OnEvent",

    -- Functions
    "CreateFrame",
    "IsShiftKeyDown",
    "RegisterStateDriver",
    "GetQuestGreenRange",
    "GetSpellPowerCost",
    "GetTime",
    "UnitClass",
    "UnitClassBase",
    "UnitIsConnected",
    "UnitIsDead",
    "UnitIsFeignDeath",
    "UnitLevel",
    "UnitName",
    "UnitPower",
    "UnitPowerMax",
    "ToggleDropDownMenu",
    "UnitFrame_OnEnter",
    "UnitFrame_OnLeave",

    -- Libraries
    "C_Timer",
    "C_UnitAuras",
}
