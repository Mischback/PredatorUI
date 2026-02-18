--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local ADDON_NAME, ns = ...

-- Grab other modules of *this* addon
local settings = ns.settings
local frames = ns.frames

-- Get a reference to oUF
local oUF = ns.oUF


local debugging = function(text)
    DEFAULT_CHAT_FRAME:AddMessage('|cff79c947Predator|r|cffffffffUnitFrames|r: |cffeeeeee'..text..'|r')
end

local ctrl = CreateFrame("Frame")
ctrl:RegisterEvent("ADDON_LOADED")
ctrl:SetScript("OnEvent", function(self, event, addon)
    if (addon ~= ADDON_NAME) then
        return
    end

    if PredatorUnitFramesSettings == nil then
        debugging("Creating default settings...")
        PredatorUnitFramesSettings = settings.createDefaults()
    end

    oUF:RegisterStyle("PredatorUF_player", frames.createPlayer)
    oUF:RegisterStyle("PredatorUF_target", frames.createTarget)
    oUF:RegisterStyle("PredatorUF_targettarget", frames.createTargetTarget)
    oUF:RegisterStyle("PredatorUF_focus", frames.createFocus)
    oUF:RegisterStyle("PredatorUF_party", frames.createPartyMember)
    oUF:RegisterStyle("PredatorUF_playercastbar_simple", frames.createPlayerCastbarSimple)

    oUF:SetActiveStyle("PredatorUF_player")
    oUF:Spawn("player", "PredatorUF_player"):SetPoint(unpack(PredatorUnitFramesSettings.player.position))

    oUF:SetActiveStyle("PredatorUF_target")
    oUF:Spawn("target", "PredatorUF_target"):SetPoint(unpack(PredatorUnitFramesSettings.target.position))

    oUF:SetActiveStyle("PredatorUF_targettarget")
    oUF:Spawn("targettarget", "PredatorUF_targettarget"):SetPoint(unpack(PredatorUnitFramesSettings.targettarget.position))

    oUF:SetActiveStyle("PredatorUF_focus")
    oUF:Spawn("focus", "PredatorUF_focus"):SetPoint(unpack(PredatorUnitFramesSettings.focus.position))

    -- TODO: Heavily work in progress!!!
    -- PlayerCastingBarFrame
    if PredatorUnitFramesSettings.playerCastbar.useThis then
        if PredatorUnitFramesSettings.playerCastbar.mode == "simple" then
            oUF:SetActiveStyle("PredatorUF_playercastbar_simple")
        end
        oUF:Spawn("player", "PredatorUF_playercastbar"):SetPoint("CENTER", UIParent, "CENTER", 0, -150)
        local cb = _G["PlayerCastingBarFrame"]
        cb:Hide()
        cb:UnregisterAllEvents()
    end

    -- FIXME: Just for development!
    oUF:SetActiveStyle("PredatorUF_party")
    oUF:Spawn("focus", "PredatorUF_partytest1"):SetPoint("BOTTOMRIGHT", "PredatorUF_player", "TOPLEFT", 0, 100)
    oUF:Spawn("focus", "PredatorUF_partytest2"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest1", "TOPLEFT", 0, 15)
    oUF:Spawn("focus", "PredatorUF_partytest3"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest2", "TOPLEFT", 0, 15)
    oUF:Spawn("focus", "PredatorUF_partytest4"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest3", "TOPLEFT", 0, 15)

    self:UnregisterEvent("ADDON_LOADED")
    debugging("loaded successfully!")
end)
