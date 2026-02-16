--[[ Provide the addon's core functionality.

  This addon does not really create ActionButtons for the player, it just
  steals the buttons from Blizzard's UI, makes them configurable and prohibits
  further changes to those buttons.

  The styling of buttons has to be done with a dedicated addon. It's as simple
  as providing a styling function, which will be called for all of the visible
  ActionButtons.

  This addon will take care of getting rid of Blizzard's default UI artwork.
]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============

local ceil = math.ceil
local floor = math.floor
local min = math.min


-- Grab other modules of *this* addon
local settings = ns.settings

-- localize some functions for performance
local unpack = unpack


local core = {}
core.buttonFuncProxy = {}


--[[ Store references to some button functions locally and remove them from
     the buttons.

  VOID proxifyButton()
  :param: btn FRAME - The button to modify.

  We don't want "others" (other addons or the default UI) to mess with our
  buttons. ``proxifyButton()`` removes some standard method from the buttons.
  However, **we** can still mess with the buttons.
]]
local proxifyButton = function(btn)
    local bname = btn:GetName()
    if not core.buttonFuncProxy[bname.."SetSize"] then
        core.buttonFuncProxy[bname.."SetSize"] = btn.SetSize
        btn.SetSize = core.noop
    end
    if not core.buttonFuncProxy[bname.."SetPoint"] then
        core.buttonFuncProxy[bname.."SetPoint"] = btn.SetPoint
        btn.SetPoint = core.noop
    end
end


--[[ Change dimensions of a button through our internal proxy.

  VOID scaleButton()
  :param: btn FRAME - The button to modify/scale
  :param: sizeX INT - X-dimension
  :param: sizeY INT - Y-dimension
]]
local scaleButton = function(btn, sizeX, sizeY)
    core.buttonFuncProxy[btn:GetName().."SetSize"](btn, sizeX, sizeY)

    btn.icon:ClearAllPoints()
    btn.icon:SetAllPoints(btn)
    btn.Flash:ClearAllPoints()
    btn.Flash:SetAllPoints(btn)
    btn.cooldown:ClearAllPoints()
    btn.cooldown:SetAllPoints(btn)

    btn.NormalTexture:ClearAllPoints()
    btn.NormalTexture:SetAllPoints(btn)
    btn.PushedTexture:ClearAllPoints()
    btn.PushedTexture:SetAllPoints(btn)
    btn.HighlightTexture:ClearAllPoints()
    btn.HighlightTexture:ClearAllPoints()
    btn.CheckedTexture:SetAllPoints(btn)
    btn.CheckedTexture:SetAllPoints(btn)
end


--[[ Move a button through our internal proxy.

  VOID moveButton()
  :param: btn FRAME - The button to move
  :param: pos TABLE - A table containing the new position. Same as
                      ``SetPoint()`` would expect.
]]
local moveButton = function(btn, pos)
    btn:ClearAllPoints()
    core.buttonFuncProxy[btn:GetName().."SetPoint"](btn, unpack(pos))
end


--[[ Apply a style function to all visible buttons of a single bar.

  VOID applyStyleToBar()
  :param: key STRING - The string to access relevant settings
  :param: func FUNCTION - The skin's styling function. Will be called with
                          the current button.
]]
local applyStyleToBar = function(key, func)
    local btn
    for i = 1, PredatorButtonsSettings[key].buttons do
        btn = _G[settings.static.ButtonPrefix[key]..i]
        func(btn)
    end
end


--[[ Debugging to ChatFrame
  VOID debugging(STRING text)
]]
core.debugging = function(text)
    DEFAULT_CHAT_FRAME:AddMessage('|cff79c947Predator|r|cffffffffButtons|r: |cffeeeeee'..text..'|r')
end


--[[ Fetch the buttons from a (Blizzard) bar and move them to this addon's frames.

  VOID processBarButtons()
  :param: key STRING - The string to access settings
  :param: parent FRAME - The new frame to attach the buttons to
]]
core.processBarButtons = function(key, parent)
    local btn
    local sizeX = PredatorButtonsSettings[key].sizeX
    local sizeY = PredatorButtonsSettings[key].sizeY
    for i = 1, settings.static.NumButtons[key] do
        btn = _G[settings.static.ButtonPrefix[key]..i]
        proxifyButton(btn)

        if i <= PredatorButtonsSettings[key].buttons then
            scaleButton(btn, sizeX, sizeY)
            moveButton(btn,
                {
                    'TOPLEFT',
                    parent,
                    'TOPLEFT',
                    ( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].sizeX+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
                    -( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].sizeY+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )} )
        else
            btn:ClearAllPoints()
            core.buttonFuncProxy[btn:GetName().."SetPoint"](btn, "BOTTOMRIGHT", UIParent, "TOPLEFT", -5, 5)
        end
    end
end


--[[ Just do nothing.

  We don't want "others" (other addons or the default UI) to mess with our
  buttons. ``proxifyButton()`` removes some standard method from the buttons.
  However, **we** can still mess with the buttons.
]]
core.noop = function() end


--[[ Lookup the correct page for the primary ActionBar.

  STRING getActionBarPage()

  To be honest, I don't totally understand the inner mechanics of the
  ActionBar paging. In fact, this is one of the reasons why I just steal
  Blizzard's default buttons instead of re-implementing them. This function is
  copied from Blizzard's UI code.
]]
core.getActionBarPage = function()
    local condition = settings.static.BlizzardActionBarPage['DEFAULT']
    local page = settings.static.BlizzardActionBarPage[settings.playerClass]
    if page then
        condition = condition.." "..page
    end
    condition = condition.." 1"
    return condition
end


--[[ Apply a style to all bars.

  VOID applyStyle()
  :param: func FUNCTION - The skin's styling function. Will be called on all
                          bars for all (visible) buttons.
]]
core.applyStyle = function(func)
    for key, _ in pairs(settings.static.BarName) do
        applyStyleToBar(key, func)
    end
end


--[[
]]
core.hideBlizzardActionBarArt = function()
    local f
    for _, v in pairs(settings.static.BlizzardDefaultFrames) do
        f = _G[v]
        f:SetAlpha(0)
        f:Hide()
    end
end


--[[ Process one single bar.

  FRAME createBar()
  :param: key STRING - The string to access relevant settings

  Blizzard's default UI provides several different bars for the player. In fact,
  there are even more than are accessible by default.
  As of now, the UI has EIGHT bars for the player (+ some stance-specific ones,
  that are usually hidden from the player).
  However, 8 bars with 12 buttons each is more than enough for me, so we
  don't mess with the system deeply. Instead, we just grab the buttons and make
  them movable and sizeable through this addon.

  Create and return an addon-specific frame to hold the buttons of a (Blizzard)
  bar specified by ``key``.
]]
core.createBar = function(key)
    local f = CreateFrame("FRAME", settings.static.BarName[key], UIParent, "SecureHandlerStateTemplate")

    f:SetSize(
        min(PredatorButtonsSettings[key].buttons, PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].sizeX+(2*PredatorButtonsSettings[key].padding)),
        ceil(PredatorButtonsSettings[key].buttons/PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].sizeY+(2*PredatorButtonsSettings[key].padding))
    )

    f:SetPoint(unpack(PredatorButtonsSettings[key].position))
    f:SetFrameLevel(100)

    core.processBarButtons(key, f)

    return f
end


ns.core = core
