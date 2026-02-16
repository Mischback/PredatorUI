std = "lua51"

quiet = 1  -- suppress output for clean files

ignore = {
    "212/msg",  -- unused argument ``msg``
    "212/self",  -- unused argument ``self``
    "212/event",  -- unused argument ``event``
    "431",  -- shadowing an upvalue
    "631",  -- line is too long
}

-- keep this empty!
exclude_files = {}

globals = {
    -- our addons' global namespaces
    "PredatorButtons",

    -- Our addons' SavedVariables
    "PredatorButtonsSettings",
    "PredatorMinimapSettings",

    -- Slash Commands
    "SLASH_PREDATORBUTTONS1",
    "SLASH_PREDATORBUTTONS2",

    -- Blizzard stuff we mess with
    "SlashCmdList",
}

read_globals = {
    -- Blizzard UI functions
    "UIParent",
    "DEFAULT_CHAT_FRAME",
    "MainMenuBar_OnEvent",

    -- Functions
    "CreateFrame",
    "IsShiftKeyDown",
    "RegisterStateDriver",
    "UnitClass",
}
