--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local ADDON_NAME, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
-- Grab other modules of *this* addon
local settings = ns.settings
local core = ns.core

local config = {}
config.configFrames = {}

local PBCONFIGMODE = {
    ["MOVE"] = "move",
    ["BUTTONS"] = "buttons",
    ["COLUMNS"] = "columns",
    ["PADDING"] = "padding",
    ["SIZE"] = "size",
}


local cycleConfigMode = function(configFrame, btn)
    if btn ~= "LeftButton" then return end

    if configFrame.mode == PBCONFIGMODE["MOVE"] then
        configFrame.mode = PBCONFIGMODE["BUTTONS"]
        configFrame.curMode:SetFormattedText(
            "Mode: %s (%d)",
            "Buttons",
            PredatorButtonsSettings[configFrame.key].buttons)
        -- TODO: Make NOT draggable
    elseif configFrame.mode == PBCONFIGMODE["BUTTONS"] then
        configFrame.mode = PBCONFIGMODE["COLUMNS"]
        configFrame.curMode:SetFormattedText(
            "Mode: %s (%d)",
            "Columns",
            PredatorButtonsSettings[configFrame.key].columns)
    elseif configFrame.mode == PBCONFIGMODE["COLUMNS"] then
        configFrame.mode = PBCONFIGMODE["PADDING"]
        configFrame.curMode:SetFormattedText(
            "Mode: %s (%d)",
            "Padding",
            PredatorButtonsSettings[configFrame.key].padding)
    elseif configFrame.mode == PBCONFIGMODE["PADDING"] then
        configFrame.mode = PBCONFIGMODE["SIZE"]
        configFrame.curMode:SetFormattedText(
            "Mode: %s (%d, %d)",
            "Size",
            PredatorButtonsSettings[configFrame.key].sizeX,
            PredatorButtonsSettings[configFrame.key].sizeY)
    elseif configFrame.mode == PBCONFIGMODE["SIZE"] then
        configFrame.mode = PBCONFIGMODE["MOVE"]
        configFrame.curMode:SetFormattedText(
            "Mode: %s",
            "Move")
        -- TODO: Make draggable
    end
end


--[[
]]
local createBarConfigFrame = function(key)
    local f = CreateFrame("FRAME", settings.static.BarName[key].."Mover", UIParent)
    f:SetAllPoints(_G[settings.static.BarName[key]])
    f:SetFrameLevel(_G[settings.static.ButtonPrefix[key].."1"]:GetFrameLevel()+50)

    f.tex = f:CreateTexture(nil, "BACKGROUND")
    f.tex:SetAllPoints()
    -- TODO: evaluate the color!
    f.tex:SetColorTexture(0, 1, 0, 0.75)

    -- TODO: evaluate the font face
    f.caption = f:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    f.caption:SetPoint("TOPLEFT")
    f.caption:SetText(settings.static.BarName[key])

    -- TODO: evaluate the font face
    f.curMode = f:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    f.curMode:SetPoint("TOPLEFT", f.caption, "BOTTOMLEFT", 5, -5)
    f.curMode:SetText("Mode: Move")

    f.key = key
    f.mode = PBCONFIGMODE["MOVE"]

    f:SetScript("OnMouseUp", cycleConfigMode)

    return f
end


--[[
]]
config.createConfigFrames = function()
    config.configFrames["ActionBar"] = createBarConfigFrame("ActionBar")
    config.configFrames["ActionBar2"] = createBarConfigFrame("ActionBar2")
    config.configFrames["ActionBar3"] = createBarConfigFrame("ActionBar3")
    config.configFrames["ActionBar4"] = createBarConfigFrame("ActionBar4")
    config.configFrames["ActionBar5"] = createBarConfigFrame("ActionBar5")
    config.configFrames["ActionBar6"] = createBarConfigFrame("ActionBar6")
    config.configFrames["ActionBar7"] = createBarConfigFrame("ActionBar7")
    config.configFrames["ActionBar8"] = createBarConfigFrame("ActionBar8")
    config.configFrames["StanceBar"] = createBarConfigFrame("StanceBar")
end


config.SlashCmdHandler = function(msg)
    local cmd, param = msg:match('^(%S*)%s*(.-)$')
    if cmd ~= "config" then return end

    local check = config.configFrames["ActionBar"]

    if check == nil then
        config.createConfigFrames()
    elseif check:IsShown() then
        -- check:Hide()
        for _, f in pairs(config.configFrames) do
            f:EnableMouse(false)
            f:Hide()
        end
    elseif not check:IsShown() then
        for _, f in pairs(config.configFrames) do
            f:Show()
            f:EnableMouse(true)
        end
    else
        print("Something went wrong")
    end
end


ns.config = config
