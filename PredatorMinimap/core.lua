-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
-- Grab other modules of *this* addon
local settings = ns.settings

local core = {}


--[[ Debugging to ChatFrame
  VOID debugging(STRING text)
]]
core.debugging = function(text)
    DEFAULT_CHAT_FRAME:AddMessage('|cff79c947Predator|r|cffffffffMinimap|r: |cffeeeeee'..text..'|r')
end


--[[ Makes the Minimap square'ish.

  STRING setMinimapShape()
]]
local setMinimapShape = function()
    return "SQUARE"
end


--[[ Hide a given frame and keep it hidden.

  VOID handlerAlwaysHide()
  :param: frame FRAME - The frame to hide
]]
local alwaysHide = function(frame)
    if frame then
        frame:Hide()
        frame:SetScript("OnShow", function(self) self:Hide() end)
    end
end


--[[ Strip the Minimap of all Blizzard stuff we don't use.

  VOID hideDefaultStuff()

  This includes visual/artwork elements **and** functions!
]]
local hideDefaultStuff = function()
    -- simply hide some stuff of the MinimapCluster
    local cluster = _G["MinimapCluster"]
    alwaysHide(cluster.BorderTop)
    alwaysHide(cluster.ZoneTextButton)
    alwaysHide(cluster.ToggleButton)

    -- hide some stuff of the actual Minimap
    alwaysHide(_G["MinimapZoomIn"])
    alwaysHide(_G["MinimapZoomOut"])
    -- TODO: Add a North tag in Predator-style?
    alwaysHide(_G["MinimapNorthTag"])
    alwaysHide(_G["MinimapCompassTexture"])
    alwaysHide(_G["MinimapBorder"])

    -- get rid of the "GameTimeFrame"
    -- This is the box with a sun/moon symbol, attached to the default Minimap.
    -- There is some calender-function attached, but afaik this is not yet
    -- available in TBC (and I don't use it anyway).
    alwaysHide(_G["GameTimeFrame"])
end


--[[
    VOID handlerZoom()
    :param: self FRAME - **Must** be the Minimap, not any other frame!
    :param: delta INT - Provides the scroll offset/direction
]]
local handlerZoom = function(mm, delta)
    local curZoom = mm:GetZoom()

    if delta > 0 and curZoom < settings.static.blizzard["maxZoomLevel"] then
        mm:SetZoom(curZoom + 1)
    end

    if delta < 0 and curZoom > 0 then
        mm:SetZoom(curZoom - 1)
    end
    core.resetZoom()
end


--[[ Applies the (user-specified) default zoom level.

  VOID setDefaultZoom()
]]
local setDefaultZoom = function()
    core.minimap:SetZoom(PredatorMinimapSettings["defaultZoomLevel"])
end


--[[ Reset the Minimap zoom level after a user-provided delay.

  VOID autoResetZoom()

  This is working and *good enough*.
  ``handlerZoom()`` calls the function ``core.resetZoom()``, which is either
  a noop or this function (depending on SavedVariables).
  The problem with this approach: The timer is activated after the very first
  zooming activity, so it *may* trigger while the user is still messing with
  the Minimap.

  TODO:
  A better implementation would work like this:
  The zoom handler *flags* the requirement to be resetted, while the actual
  timer is called/triggered when the mouse pointer leaves the frame.
]]
local autoResetZoom = function()
    C_Timer.After(PredatorMinimapSettings["resetZoomDelay"], setDefaultZoom)
end


--[[ Grab and modify the mail icon

  VOID modifyMailIcon()
  :param: frame FRAME - Blizzard's mail icon

  Removes Blizzard's visuals completely and replaces them with a custom mail
  icon.
]]
local modifyMailIcon = function(frame)
    alwaysHide(_G["MiniMapMailBorder"])
    alwaysHide(_G["MiniMapMailIcon"])

    -- create an alternative icon
    -- TODO: We're reusing the tracking icon for mailboxes. This might be
    --       problematic, because we can have essentially some obfuscation. We
    --       flip the icon, to make them distinguishable. But this may need
    --       another look.
    frame.newIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.newIcon:SetAllPoints()
    frame.newIcon:SetTexture("Interface\\MINIMAP\\TRACKING\\Mailbox")
    frame.newIcon:SetTexCoord(1, 0, 0, 1)
    -- frame.newIcon:SetColorTexture(0, 1, 0, 1)

    -- TODO: Make the position configurable
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOMRIGHT", core.minimap, "BOTTOMRIGHT", -3, 3)
    frame:SetSize(18, 18)
end


--[[ Grab and modify the tracker icon

  VOID modifyTrackerIcon()
  :param: frame FRAME - Blizzard's tracker icon

  Removes Blizzard's decorational elements but keeps the actual icon.
]]
local modifyTrackerIcon = function(frame)
    frame:SetParent(core.minimap)

    alwaysHide(_G["MiniMapTrackingBackground"])
    alwaysHide(_G["MiniMapTrackingOverlay"])
    alwaysHide(_G["MiniMapTrackingButtonBorder"])

    -- TODO: Make the position configurable
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", core.minimap, "TOPLEFT", -4, 4)
end


local modifyLfgIcon = function(frame)
    frame:SetParent(core.minimap)

    alwaysHide(_G["LFGMinimapFrameBorder"])

    -- TODO: Make the position configurable
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", core.minimap, "TOPRIGHT", 5, 5)
end


--[[ Just do nothing.

  VOID noop()

  This is meant to replace other functions when their execution is not desired.
]]
core.noop = function()
    return
end


--[[ Used in the ``handlerZoom()`` to setup a time-based auto reset or not.

  VOID resetZoom()
]]
core.resetZoom = core.noop


--[[ Provide a dedicated setup.

  VOID setupMinimap()

  We don't really re-implement the Minimap, but re-use the existing one.
]]
core.setupMinimap = function()
    -- get a reference
    core.mailIcon = _G["MiniMapMailFrame"]
    core.trackerIcon = _G["MiniMapTracking"]
    core.lfgIcon = _G["LFGMinimapFrame"]

    -- save the maximum zoom level for later usage
    -- Ref: https://warcraft.wiki.gg/wiki/API_Minimap_GetZoomLevels
    --
    -- Used by SetZoom(), returned by GetZoom()
    settings.static.blizzard["maxZoomLevel"] = core.minimap:GetZoomLevels() - 1

    -- get rid of default stuff
    hideDefaultStuff()

    -- make the minimap square!
    _G["GetMinimapShape"] = setMinimapShape
    core.minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")

    -- Mail Icon
    modifyMailIcon(core.mailIcon)

    -- Tracker Icon
    modifyTrackerIcon(core.trackerIcon)

    -- LFG status Icon
    if core.lfgIcon then
        modifyLfgIcon(core.lfgIcon)
    end

    -- Battlefield
    -- TODO: process this! Thing is, I want to provide the LFG queue thingy in
    --       the top right corner and this one below that. So I need the LFG
    --       queue thingy (and its position) as reference.

    -- zooming with the scroll wheel
    core.minimap:EnableMouseWheel(true)
    core.minimap:SetScript("OnMouseWheel", handlerZoom)

    -- auto reset zoom
    if PredatorMinimapSettings["autoResetZoom"] then
        core.resetZoom = autoResetZoom
    end


    -- Apply position and sizefrom SavedVariables
    core.minimap:SetSize(PredatorMinimapSettings.size, PredatorMinimapSettings.size)
    core.minimap:ClearAllPoints()
    core.minimap:SetPoint(
        PredatorMinimapSettings["position"][1],
        UIParent,
        PredatorMinimapSettings["position"][2],
        PredatorMinimapSettings["position"][3]
    )
end


--[[ Apply an external style function to the Minimap

  VOID applyStyle()
  :param: func FUNCTION - The function to call on the Minimap
]]
core.applyStyle = function(func)
    if not func then return end

    func(core.minimap)
end


ns.core = core
