--[[

]]

-- Provide addon-specific environment, don't work on global namespace
local ADDON_NAME, ns = ...

-- Grab other modules of *this* addon
local settings = ns.settings
local frames = ns.frames

-- Get a reference to oUF
local oUF = ns.oUF


local UnitLevel = UnitLevel
local GetQuestGreenRange = GetQuestGreenRange


local debugging = function(text)
    DEFAULT_CHAT_FRAME:AddMessage('|cff79c947Predator|r|cffffffffUnitFrames|r: |cffeeeeee'..text..'|r')
end


--[[ Spawning the frames using oUF.

  VOID spawnFrames()
]]
local spawnFrames = function()
    oUF:RegisterStyle("PredatorUF_player", frames.createPlayer)
    oUF:RegisterStyle("PredatorUF_target", frames.createTarget)
    oUF:RegisterStyle("PredatorUF_targettarget", frames.createTargetTarget)
    oUF:RegisterStyle("PredatorUF_pet", frames.createPet)
    oUF:RegisterStyle("PredatorUF_focus", frames.createFocus)
    oUF:RegisterStyle("PredatorUF_party", frames.createPartyMember)
    oUF:RegisterStyle("PredatorUF_playercastbar_simple", frames.createPlayerCastbarSimple)

    oUF:SetActiveStyle("PredatorUF_player")
    local playerUF = oUF:Spawn("player", "PredatorUF_player")
    playerUF:SetPoint(unpack(PredatorUnitFramesSettings.player.position))
    -- playerUF:EnableElement("MP5player")

    oUF:SetActiveStyle("PredatorUF_pet")
    oUF:Spawn("pet", "PredatorUF_pet"):SetPoint(unpack(PredatorUnitFramesSettings.pet.position))

    oUF:SetActiveStyle("PredatorUF_target")
    oUF:Spawn("target", "PredatorUF_target"):SetPoint(unpack(PredatorUnitFramesSettings.target.position))

    oUF:SetActiveStyle("PredatorUF_targettarget")
    oUF:Spawn("targettarget", "PredatorUF_targettarget"):SetPoint(unpack(PredatorUnitFramesSettings.targettarget.position))

    oUF:SetActiveStyle("PredatorUF_focus")
    oUF:Spawn("focus", "PredatorUF_focus"):SetPoint(unpack(PredatorUnitFramesSettings.focus.position))

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

    oUF:SetActiveStyle("PredatorUF_party")
    local party = oUF:SpawnHeader("PredatorUF_party", nil,
    -- "custom [@raid6,exists] hide; [@raid1,exists] show; [group:party,nogroup:raid] show; hide",
    {
        ["showPlayer"] = true,  -- FIXME: Make configurable
        ["showSolo"] = true,  -- FIXME: Should be ``false`` for production!
        ["showParty"] = true,
        ["showRaid"] = false,
        ["groupBy"] = "ROLE",
        ["groupingOrder"] = "TANK,HEAL,DAMAGE",  -- FIXME: Make configurable
        ["sortMethod"] = "NAME",
        ["point"] = "BOTTOM",
        ["maxColumns"] = 1,
        ["unitsPerColumn"] = 5,
        ["columnSpacing"] = 0,
        ["xOffset"] = 0,
        ["yOffset"] = 10,
        ["columnAnchorPoint"] = "BOTTOM",
        -- ["oUF-initialConfigFunction"] = format([[
        --    self:SetWidth(%d)
        --     self:SetHeight(%d)
        -- ]], 72, 28),
    })
    party:SetPoint(unpack(PredatorUnitFramesSettings.party.position))
    party:Show()  -- TODO: Is this required or will this happen automatically
                  --       when the player enters a group?

    -- FIXME: Just for testing / development!
    -- oUF:Spawn("focus", "PredatorUF_partytest1"):SetPoint("BOTTOMRIGHT", "PredatorUF_player", "TOPLEFT", 0, 100)
    -- oUF:Spawn("focus", "PredatorUF_partytest2"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest1", "TOPLEFT", 0, 10)
    -- oUF:Spawn("focus", "PredatorUF_partytest3"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest2", "TOPLEFT", 0, 10)
    -- oUF:Spawn("focus", "PredatorUF_partytest4"):SetPoint("BOTTOMLEFT", "PredatorUF_partytest3", "TOPLEFT", 0, 10)
end


--[[ Cache the player's level.

  VOID updatePlayerLevel()
  :param: newLevel INT - The player's level

  This function will update the internal tracking of the player's level (and
  the respective minimum enemy level for experience). The information is used
  in the target unitframe's name update function.
]]
local updatePlayerLevel = function(newLevel)
    settings.general.playerLevel = newLevel
    settings.general.questGreenLevel = newLevel - GetQuestGreenRange()
end


local ctrl = CreateFrame("Frame")
ctrl:RegisterEvent("ADDON_LOADED")  -- (self, event, addon)
ctrl:RegisterEvent("PLAYER_LEVEL_UP")  -- (self, event, newLevel)
ctrl:SetScript("OnEvent", function(self, event, param1)
    if event == "ADDON_LOADED" then
        if (param1 ~= ADDON_NAME) then
            return
        end

        if PredatorUnitFramesSettings == nil then
            debugging("Creating default settings...")
            PredatorUnitFramesSettings = settings.createDefaults()
        end

        settings.general.playerClass = UnitClassBase("player")
        updatePlayerLevel(UnitLevel("player"))
        spawnFrames()

        self:UnregisterEvent("ADDON_LOADED")
        debugging("loaded successfully!")
    end

    if event == "PLAYER_LEVEL_UP" then
        updatePlayerLevel(param1)
    end
end)
