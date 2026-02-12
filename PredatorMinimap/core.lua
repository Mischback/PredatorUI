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


--[[ Provide a dedicated setup.

  VOID setupMinimap()

  We don't really re-implement the Minimap, but re-use the existing one.
]]
core.setupMinimap = function()
    -- get a reference
    core.minimap = _G["Minimap"]

    -- get rid of default stuff
    hideDefaultStuff()

    -- make the minimap square!
    _G["GetMinimapShape"] = setMinimapShape
    core.minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
end

ns.core = core
