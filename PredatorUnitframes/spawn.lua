--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local ADDON_NAME, ns = ...

-- Grab other modules of *this* addon
local settings = ns.settings  -- Luacheck: ignore
local frames = ns.frames

-- Get a reference to oUF
local oUF = ns.oUF
assert(oUF, "PredatorUnitframes require an oUF core")


local ctrl = CreateFrame("Frame")
ctrl:RegisterEvent("ADDON_LOADED")
ctrl:SetScript("OnEvent", function(self, event, addon)
    if (addon ~= ADDON_NAME) then
        return
    end

    oUF:RegisterStyle("PredatorUF_player", frames.createPlayer)
    oUF:RegisterStyle("PredatorUF_target", frames.createTarget)
    oUF:RegisterStyle("PredatorUF_targettarget", frames.createTargetTarget)
    oUF:RegisterStyle("PredatorUF_focus", frames.createFocus)
    oUF:RegisterStyle("PredatorUF_party", frames.createPartyMember)
    oUF:RegisterStyle("PredatorUF_playercastbar_simple", frames.createPlayerCastbarSimple)

    oUF:SetActiveStyle("PredatorUF_player")
    oUF:Spawn("player", "PredatorUF_player"):SetPoint("RIGHT", UIParent, "CENTER", -75, -250)

    oUF:SetActiveStyle("PredatorUF_target")
    oUF:Spawn("target", "PredatorUF_target"):SetPoint("LEFT", UIParent, "CENTER", 75, -250)

    oUF:SetActiveStyle("PredatorUF_targettarget")
    oUF:Spawn("targettarget", "PredatorUF_targettarget"):SetPoint("LEFT", "PredatorUF_target", "RIGHT", 20, 0)

    oUF:SetActiveStyle("PredatorUF_focus")
    oUF:Spawn("focus", "PredatorUF_focus"):SetPoint("BOTTOMLEFT", "PredatorUF_targettarget", "TOPLEFT", 0, 100)

    -- TODO: Heavily work in progress!!!
    oUF:SetActiveStyle("PredatorUF_playercastbar_simple")
    oUF:Spawn("player", "PredatorUF_playercastbar"):SetPoint("CENTER", UIParent, "CENTER", 0, -150)

    -- FIXME: Just for development!
    oUF:SetActiveStyle("PredatorUF_party")
    oUF:Spawn("focus", "PredatorUF_partytest1"):SetPoint("BOTTOMRIGHT", "PredatorUF_player", "TOPLEFT", 0, 100)
    oUF:Spawn("focus", "PredatorUF_partytest2"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest1", "TOPLEFT", 0, 15)
    oUF:Spawn("focus", "PredatorUF_partytest3"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest2", "TOPLEFT", 0, 15)
    oUF:Spawn("focus", "PredatorUF_partytest4"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest3", "TOPLEFT", 0, 15)
end)
