std = "lua51"

quiet = 1  -- suppress output for clean files

-- keep this empty!
exclude_files = {}

globals = {
    -- Our addons' SavedVariables
    "PredatorButtonsSettings",
    "PredatorMinimapSettings",
}

read_globals = {
    -- Blizzard UI functions
    UIParent,

    -- Functions
    CreateFrame,
    IsShiftKeyDown,
}
