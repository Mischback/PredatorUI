std = "lua51"

quiet = 1  -- suppress output for clean files

ignore = {
    "212/msg",  -- unused argument ``msg``
    "631",  -- line is too long
}

-- keep this empty!
exclude_files = {}

globals = {
    -- Our addons' SavedVariables
    "PredatorButtonsSettings",
    "PredatorMinimapSettings",
}

read_globals = {
    -- Blizzard UI functions
    "UIParent",
    "DEFAULT_CHAT_FRAME",

    -- Functions
    "CreateFrame",
    "IsShiftKeyDown",
}
