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
local handlerZoom = function(self, delta)
    curZoom = self:GetZoom()

    if delta > 0 and curZoom < settings.static.blizzard["maxZoomLevel"] then
        self:SetZoom(curZoom + 1)
    end

    if delta < 0 and curZoom > 0 then
        self:SetZoom(curZoom - 1)
    end
    core.resetZoom()
end


--[[ Applies the (user-specified) default zoom level.

  VOID setDefaultZoom()
]]
local setDefaultZoom = function()
    core.minimap:SetZoom(settings.user["defaultZoomLevel"])
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
    C_Timer.After(settings.user["resetZoomDelay"], setDefaultZoom)
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
    core.minimap = _G["Minimap"]

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

    -- zooming with the scroll wheel
    core.minimap:EnableMouseWheel(true)
    core.minimap:SetScript("OnMouseWheel", handlerZoom)

    -- auto reset zoom
    if settings.user["autoResetZoom"] then
        core.resetZoom = autoResetZoom
    end
end

ns.core = core
