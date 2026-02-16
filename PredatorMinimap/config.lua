
-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
-- Grab other modules of *this* addon
local settings = ns.settings
local core = ns.core

local config = {}

local configFrame = nil
local PMCONFIGMODE = {
    ["MOVE"] = "move",
    ["SIZE"] = "size",
}


--[[ Handler to adjust the size of the minimap.

  VOID scrollingForSize()
  :param: configFrame FRAME - The frame receiving the scroll event
  :param: delta INT - The actual scrolling
]]
local scrollingForSize = function(configFrame, delta)
    local tmp = core.minimap:GetWidth()

    if delta > 0 then
        tmp = tmp + 1
    else
        tmp = tmp -1
    end

    PredatorMinimapSettings.size = tmp

    configFrame.curMode:SetFormattedText(
        "Mode: %s (%d)",
        "Size",
        PredatorMinimapSettings.size)
end


--[[ Event handler for scrolling on the config frame.

  VOID configScrollHandler()
  :param: configFrame FRAME - The frame receiving the scroll event
  :param: delta INT - The actual scrolling.

  This function only delegates the actual processing based on the currently
  active config mode and applies the changes afterwards to the bar and its
  buttons.
]]
local configScrollHandler = function(configFrame, delta)
    if configFrame.mode == PMCONFIGMODE["SIZE"] then
        scrollingForSize(configFrame, delta)
    end

    core.minimap:SetSize(PredatorMinimapSettings.size, PredatorMinimapSettings.size)
    configFrame:ClearAllPoints()
    configFrame:SetAllPoints(core.minimap)
end


--[[ Event handler for dragging.

  VOID dragMapStart()
  :param: configFrame FRAME - The dragged frame.
]]
local dragMapStart = function(configFrame)
    -- configFrame:ClearAllPoints()
    configFrame:StartMoving()
end


--[[ Event handler for dragging. Stores the new position.

  VOID dragMapStop()
  :param: configFrame FRAME - The dragged frame.
]]
local dragMapStop = function(configFrame)
    configFrame:StopMovingOrSizing()

    local anchor, _, relAnchor, xOffset, yOffset = configFrame:GetPoint(1)
    core.minimap:ClearAllPoints()
    core.minimap:SetPoint(anchor, UIParent, relAnchor, xOffset, yOffset)
    PredatorMinimapSettings["position"] = { anchor, xOffset, yOffset }
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

    if configFrame.mode == PMCONFIGMODE["MOVE"] then
        configFrame.mode = PMCONFIGMODE["SIZE"]

        configFrame:RegisterForDrag()
        configFrame:SetMovable(false)
        configFrame:SetScript("OnDragStart", nil)
        configFrame:SetScript("OnDragStop", nil)

        configFrame.curMode:SetFormattedText(
            "Mode: %s (%d)",
            "Size",
            PredatorMinimapSettings.size)
    elseif configFrame.mode == PMCONFIGMODE["SIZE"] then
        configFrame.mode = PMCONFIGMODE["MOVE"]

        configFrame:RegisterForDrag("LeftButton")
        configFrame:SetMovable(true)
        configFrame:SetScript("OnDragStart", dragMapStart)
        configFrame:SetScript("OnDragStop", dragMapStop)

        configFrame.curMode:SetFormattedText("Mode: %s", "Move")
    end
end


--[[ Create the config frame for the minimap.

  FRAME createConfigFrame()
  :param: key STRING - The string to access the settings

  Beside creating the actual frame this will attach the event handlers to the
  frame. Clicks (left mouse button) will cycle through the different config
  modes, scrolling will adjust the values.
]]
local createConfigFrame = function()
    local f = CreateFrame("FRAME", "PredatorMinimapConfigFrame", UIParent)

    f.mode = PMCONFIGMODE["SIZE"]

    f:SetSize(PredatorMinimapSettings.size, PredatorMinimapSettings.size)
    f:SetPoint("TOPLEFT", core.minimap, "TOPLEFT", 0, 0)
    f:SetFrameLevel(core.minimap:GetFrameLevel()+500)

    f.tex = f:CreateTexture(nil, "BACKGROUND")
    f.tex:SetAllPoints()
    f.tex:SetColorTexture(unpack(settings.static.design["configFrameBgColor"]))

    f.caption = f:CreateFontString(nil, "ARTWORK", "NumberFont_Shadow_Small")
    f.caption:SetTextColor(unpack(settings.static.design.configFrameFontColor))
    f.caption:SetPoint("TOPLEFT", 3, -3)
    f.caption:SetText("PredatorMinimap")

    f.curMode = f:CreateFontString(nil, "ARTWORK", "NumberFont_Shadow_Small")
    f.curMode:SetTextColor(unpack(settings.static.design.configFrameFontColor))
    f.curMode:SetPoint("TOPLEFT", f.caption, "BOTTOMLEFT", 5, -5)
    f.curMode:SetFormattedText(
        "Mode: %s (%d)",
        "Size",
        PredatorMinimapSettings.size)

    f:EnableMouse(true)
    f:SetScript("OnMouseUp", cycleConfigMode)
    f:SetScript("OnMouseWheel", configScrollHandler)

    return f
end


--[[ Handle the addon's slash commands.

  VOID SlashCmdHandler()
  :param: msg STRING - The whole line containing the slash command

  The slash command will show and hide the configuration frames.

  The configuration frames are created "on demand".
]]
config.SlashCmdHandler = function(msg)
    if configFrame == nil then
        configFrame = createConfigFrame()
    elseif configFrame:IsShown() then
        configFrame:Hide()
    elseif not configFrame:IsShown() then
        configFrame:Show()
    else
        core.debugging("Something went wrong!")
    end
end



ns.config = config
