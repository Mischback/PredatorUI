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

local configFrames = {}
local PBCONFIGMODE = {
    ["MOVE"] = "move",
    ["BUTTONS"] = "buttons",
    ["COLUMNS"] = "columns",
    ["PADDING"] = "padding",
    ["SIZE"] = "size",
}


--[[ Handler to adjust the number of buttons for the bar.

  VOID scrollingForColumns()
  :param: configFrame FRAME - The frame receiving the scroll event
  :param: delta INT - The actual scrolling

  Scrolling up increments the value, scrolling down decrements.
]]
local scrollingForButtons = function(configFrame, delta)
    local tmp = PredatorButtonsSettings[configFrame.key].buttons
    if delta > 0 then
        tmp = tmp + 1
        if tmp <= settings.static.NumButtons[configFrame.key] then
            PredatorButtonsSettings[configFrame.key].buttons = tmp
        end
    else
        tmp = tmp - 1
        if tmp > 0 then
            PredatorButtonsSettings[configFrame.key].buttons = tmp
        end
    end

    configFrame.curMode:SetFormattedText(
        "Mode: %s (%d)",
        "Buttons",
        PredatorButtonsSettings[configFrame.key].buttons)
end


--[[ Handler to adjust the number of columns for the bar.

  VOID scrollingForColumns()
  :param: configFrame FRAME - The frame receiving the scroll event
  :param: delta INT - The actual scrolling

  Scrolling up increments the value, scrolling down decrements.
]]
local scrollingForColumns = function(configFrame, delta)
    local tmp = PredatorButtonsSettings[configFrame.key].columns
    if delta > 0 then
        tmp = tmp + 1
        if tmp <= settings.static.NumButtons[configFrame.key] then
            PredatorButtonsSettings[configFrame.key].columns = tmp
        end
    else
        tmp = tmp - 1
        if tmp > 0 then
            PredatorButtonsSettings[configFrame.key].columns = tmp
        end
    end

    configFrame.curMode:SetFormattedText(
        "Mode: %s (%d)",
        "Columns",
        PredatorButtonsSettings[configFrame.key].columns)
end


--[[ Handler to adjust the padding of buttons.

  VOID scrollingForPadding()
  :param: configFrame FRAME - The frame receiving the scroll event
  :param: delta INT - The actual scrolling

  Scrolling up increments the value, scrolling down decrements.
]]
local scrollingForPadding = function(configFrame, delta)
    local tmp = PredatorButtonsSettings[configFrame.key].padding
    if delta > 0 then
        tmp = tmp + 1
    else
        tmp = tmp - 1
    end
    PredatorButtonsSettings[configFrame.key].padding = tmp

    configFrame.curMode:SetFormattedText(
        "Mode: %s (%d)",
        "Padding",
        PredatorButtonsSettings[configFrame.key].padding)
end


--[[ Handler to adjust the size of a button.

  VOID scrollingForSize()
  :param: configFrame FRAME - The frame receiving the scroll event
  :param: delta INT - The actual scrolling

  Normal scrolling adjusts the horizontal size, scrolling while holding down
  Shift adjusts the vertical size.
  Scrolling up increments the value, scrolling down decrements.
]]
local scrollingForSize = function(configFrame, delta)
    local tmp
    local modDown = IsShiftKeyDown()
    if modDown then
        tmp = PredatorButtonsSettings[configFrame.key].sizeY
    else
        tmp = PredatorButtonsSettings[configFrame.key].sizeX
    end

    if delta > 0 then
        tmp = tmp + 1
    else
        tmp = tmp - 1
    end

    if modDown then
        PredatorButtonsSettings[configFrame.key].sizeY = tmp
    else
        PredatorButtonsSettings[configFrame.key].sizeX = tmp
    end

    configFrame.curMode:SetFormattedText(
        "Mode: %s (%d, %d)",
        "Size",
        PredatorButtonsSettings[configFrame.key].sizeX,
        PredatorButtonsSettings[configFrame.key].sizeY)
end


--[[ Event handler for scrolling on a config frame.

  VOID configScrollHandler()
  :param: configFrame FRAME - The frame receiving the scroll event
  :param: delta INT - The actual scrolling.

  This function only delegates the actual processing based on the currently
  active config mode and applies the changes afterwards to the bar and its
  buttons.
]]
local configScrollHandler = function (configFrame, delta)
    if configFrame.mode == PBCONFIGMODE["BUTTONS"] then
        scrollingForButtons(configFrame, delta)
    elseif configFrame.mode == PBCONFIGMODE["COLUMNS"] then
        scrollingForColumns(configFrame, delta)
    elseif configFrame.mode == PBCONFIGMODE["PADDING"] then
        scrollingForPadding(configFrame, delta)
    elseif configFrame.mode == PBCONFIGMODE["SIZE"] then
        scrollingForSize(configFrame, delta)
    end

    local key = configFrame.key
    local bar = _G[settings.static.BarName[key]]
    core.processBarButtons(configFrame.key, bar)
    configFrame:ClearAllPoints()
    configFrame:SetPoint("TOPLEFT", bar)
    configFrame:SetSize(
        min(PredatorButtonsSettings[key].buttons, PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].sizeX+(2*PredatorButtonsSettings[key].padding)),
        ceil(PredatorButtonsSettings[key].buttons/PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].sizeY+(2*PredatorButtonsSettings[key].padding))
    )
    bar:SetSize(
        min(PredatorButtonsSettings[key].buttons, PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].sizeX+(2*PredatorButtonsSettings[key].padding)),
        ceil(PredatorButtonsSettings[key].buttons/PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].sizeY+(2*PredatorButtonsSettings[key].padding))
    )
    configFrame.tex:SetAllPoints(configFrame)
end


local dragBarStart = function(configFrame)
    configFrame:ClearAllPoints()
    configFrame:StartMoving()
end


local dragBarStop = function(configFrame)
    configFrame:StopMovingOrSizing()

    local anchor, _, relAnchor, xOffset, yOffset = configFrame:GetPoint()
    print(anchor)
    _G[settings.static.BarName[configFrame.key]]:ClearAllPoints()
    _G[settings.static.BarNAme[configFrame.key]]:SetPoint(anchor, UIParent, relAnchor, xOffset, yOffset)
    PredatorButtonsSettings[configFrame.key].position = { anchor, x, y }
end


--[[ Event handler for clicks on the config frames.

  VOID cycleConfigMode()
  :param: configFrame FRAME - The frame receiving the click
  :param: btn STRING - The button used for the click

  This function only reacts to clicks of the left mouse button.
  It will switch through the different config modes.
]]
local cycleConfigMode = function(configFrame, btn)
    if btn ~= "LeftButton" then return end

    if configFrame.mode == PBCONFIGMODE["BUTTONS"] then
        configFrame.mode = PBCONFIGMODE["COLUMNS"]
        configFrame.curMode:SetFormattedText(
            "Mode: %s (%d)",
            "Columns",
            PredatorButtonsSettings[configFrame.key].columns)
    elseif configFrame.mode == PBCONFIGMODE["COLUMNS"] then
        configFrame.mode = PBCONFIGMODE["MOVE"]

        -- configFrame:RegisterForDrag("LeftButton")
        -- configFrame:SetMovable(true)
        -- configFrame:SetScript("OnDragStart", dragBarStart)
        -- configFrame:SetScript("OnDragStop", dragBarStop)

        configFrame.curMode:SetFormattedText(
            "Mode: %s",
            "Move")
    elseif configFrame.mode == PBCONFIGMODE["MOVE"] then
        configFrame:RegisterForDrag()
        -- configFrame:SetMovable(false)
        -- configFrame:SetScript("OnDragStart", nil)
        -- configFrame:SetScript("OnDragStop", nil)
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
        configFrame.mode = PBCONFIGMODE["BUTTONS"]
        configFrame.curMode:SetFormattedText(
            "Mode: %s (%d)",
            "Buttons",
            PredatorButtonsSettings[configFrame.key].buttons)
    end
end


--[[ Create the config frame for a single bar.

  FRAME createBarConfigFrame()
  :param: key STRING - The string to access the settings

  Beside creating the actual frame this will attach the event handlers to the
  frame. Clicks (left mouse button) will cycle through the different config
  modes, scrolling will adjust the values.
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
    f.curMode:SetText("Mode: Buttons")

    f.key = key
    f.mode = PBCONFIGMODE["BUTTONS"]

    f:EnableMouse(true)
    f:SetScript("OnMouseUp", cycleConfigMode)
    f:SetScript("OnMouseWheel", configScrollHandler)

    return f
end


--[[ Create the config frames.

  VOID createConfigFrames
]]
local createConfigFrames = function()
    configFrames["ActionBar"] = createBarConfigFrame("ActionBar")
    configFrames["ActionBar2"] = createBarConfigFrame("ActionBar2")
    configFrames["ActionBar3"] = createBarConfigFrame("ActionBar3")
    configFrames["ActionBar4"] = createBarConfigFrame("ActionBar4")
    configFrames["ActionBar5"] = createBarConfigFrame("ActionBar5")
    configFrames["ActionBar6"] = createBarConfigFrame("ActionBar6")
    configFrames["ActionBar7"] = createBarConfigFrame("ActionBar7")
    configFrames["ActionBar8"] = createBarConfigFrame("ActionBar8")
    configFrames["StanceBar"] = createBarConfigFrame("StanceBar")
end


--[[ Handle the addon's slash commands.

  VOID SlashCmdHandler()
  :param: msg STRING - The whole line containing the slash command

  The slash command will show and hide the configuration frames.

  The configuration frames are created "on demand".
]]
config.SlashCmdHandler = function(msg)
    local cmd, param = msg:match('^(%S*)%s*(.-)$')
    if cmd ~= "config" then return end

    local check = configFrames["ActionBar"]

    if check == nil then
        createConfigFrames()
    elseif check:IsShown() then
        for _, f in pairs(configFrames) do
            f:Hide()
        end
    elseif not check:IsShown() then
        for _, f in pairs(configFrames) do
            f:Show()
        end
    else
        print("Something went wrong!")
    end
end


ns.config = config
