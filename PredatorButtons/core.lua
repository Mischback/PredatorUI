--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local ADDON_NAME, ns = ...



-- ==============
-- LOCALIZE STUFF
-- ==============
-- Grab other modules of *this* addon
local settings = ns.settings
local util = ns.util
local core = {}


local ctrl = CreateFrame("FRAME", nil, UIParent)
ctrl:RegisterEvent("ADDON_LOADED")
ctrl:SetScript("OnEvent", function(self, event, addon)
    if addon ~= ADDON_NAME then return end

    local _

    -- Initialize the Saved Variables
    if not PredatorButtonsSettings then
        print("Creating default settings for ", ADDON_NAME)
        PredatorButtonsSettings = settings.createDefaults()
    end

    _, settings.playerClass = UnitClass("player")

    local ab1 = util.createBar("ActionBar")
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
            RegisterStateDriver(self, 'page', util.getActionBarPage())
        else
            MainMenuBar_OnEvent(self, event, ...)  -- BLIZZARD
        end
    end)

    -- grab the existing ActionBars
    local ab2 = util.createBar("ActionBar2")


    -- at this point everything should be done!
    print(ADDON_NAME, "loaded...")
end)
