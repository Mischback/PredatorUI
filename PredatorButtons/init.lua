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
local config = ns.config

-- Explicit GLOBAL access to this addon
PredatorButtons = {}


local ctrl = CreateFrame("FRAME", nil, UIParent)
ctrl:RegisterEvent("ADDON_LOADED")
ctrl:SetScript("OnEvent", function(self, event, addon)
    if addon ~= ADDON_NAME then return end

    local _

    -- Initialize the Saved Variables
    if PredatorButtonsSettings == nil then
        print("Creating default settings for ", ADDON_NAME)
        PredatorButtonsSettings = settings.createDefaults()
    end

    _, settings.playerClass = UnitClass("player")

    local ab1 = core.createBar("ActionBar")
    ab1:RegisterEvent("PLAYER_LOGIN")
    ab1:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    ab1:RegisterEvent("BAG_UPDATE")
    ab1:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            local i, btn, list
            for i = 1, settings.static.NumButtons["ActionBar"] do
                btn = _G[settings.static.ButtonPrefix["ActionBar"]..i]
                btn:SetParent(self)
                self:SetFrameRef("ActionButton"..i, btn)
            end
            self:Execute([[
                list = table.new()
                for i = 1, 12 do
                    table.insert(list, self:GetFrameRef('ActionButton'..i))
                end
            ]])
            self:SetAttribute('_onstate-page', [[
                for i, button in ipairs(list) do
                    button:SetAttribute('actionpage', tonumber(newstate))
                end
            ]])
            RegisterStateDriver(self, 'page', core.getActionBarPage())
        else
            MainMenuBar_OnEvent(self, event, ...)  -- BLIZZARD
        end
    end)

    -- grab the existing ActionBars
    local ab2 = core.createBar("ActionBar2")
    _G[settings.static.BlizzardBarName["ActionBar2"]]:SetParent(ab2)
    local ab3 = core.createBar("ActionBar3")
    _G[settings.static.BlizzardBarName["ActionBar3"]]:SetParent(ab3)
    local ab4 = core.createBar("ActionBar4")
    _G[settings.static.BlizzardBarName["ActionBar4"]]:SetParent(ab4)
    local ab5 = core.createBar("ActionBar5")
    _G[settings.static.BlizzardBarName["ActionBar5"]]:SetParent(ab5)
    local ab6 = core.createBar("ActionBar6")
    _G[settings.static.BlizzardBarName["ActionBar6"]]:SetParent(ab6)
    local ab7 = core.createBar("ActionBar7")
    _G[settings.static.BlizzardBarName["ActionBar7"]]:SetParent(ab7)
    local ab8 = core.createBar("ActionBar8")
    _G[settings.static.BlizzardBarName["ActionBar8"]]:SetParent(ab8)

    local sb = core.createBar("StanceBar")
    for i = 1, settings.static.NumButtons["StanceBar"] do
        _G[settings.static.ButtonPrefix["StanceBar"]..i]:SetParent(sb)
    end

    local petb = core.createBar("PetActionBar")
    _G[settings.static.BlizzardBarName["PetActionBar"]]:SetParent(petb)


    -- STYLING
    --
    -- We provide one single function to other addons (namely, skins for the
    -- button handled by this addon), ``applyStyle()``. It will call the
    -- skin's function on every (visible) button to allow styling.
    PredatorButtons.applyStyle = core.applyStyle
    core.hideBlizzardActionBarArt()

    -- setup the slash-commands
    SLASH_PREDATORBUTTONS1, SLASH_PREDATORBUTTONS2 = "/predatorbuttons", "/pb"
    SlashCmdList["PREDATORBUTTONS"] = config.SlashCmdHandler


    -- at this point everything should be done!
    -- TODO: provide a dedicated function for *stylish* user feedback 
    --       colored addon name + message or something like that.
    print(ADDON_NAME, "loaded...")
end)
