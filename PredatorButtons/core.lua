--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
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


--[[ Fetch the buttons from a (Blizzard) bar and move them to this addon's frames.

  VOID fetchButtonsFromBar()
  :param: key STRING - The string to access settings
  :param: parent FRAME - The new frame to attach the buttons to
]]
local fetchButtonsFromBar = function(key, parent)
    local i, btn
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


--[[ Process one single bar.

  FRAME createBar()
  :param: key STRINBG - The string to access relevant settings

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
    local f = CreateFrame("FRAME", nil, UIParent, "SecureHandlerStateTemplate")

    -- TODO: Does this bar need a size?!
    f:SetSize(48, 48)
    --f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetPoint(unpack(PredatorButtonsSettings[key].position))

    fetchButtonsFromBar(key, f)

    return f
end


ns.core = core
