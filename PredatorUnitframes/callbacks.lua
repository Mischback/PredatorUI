--[[
  Provide callback functions for the actual layouts.

  oUF attaches functions to elements in order to update things, like the
  text-representation of health. This module collects all of those callbacks.
]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...

-- Localize Blizzard API functions
--
-- The callbacks inside of this module may be executed several times on several
-- different unitframes. Localizing may provide slightly better performance.
local C_UnitAuras = C_UnitAuras
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitName = UnitName
local ToggleDropDownMenu = ToggleDropDownMenu
local format = string.format

-- Grab other modules of *this* addon
local settings = ns.settings
local util = ns.util

local cb = {}


--[[ Determine of a unit is "dead" or "offline".

  STRING | nil getStatusString()
  :param: unit STRING
]]
local getStatusString = function(unit)
    if not UnitIsConnected(unit) then
        return settings.general.STATUS_OFFLINE
    end

    if UnitIsDead(unit) and not UnitIsFeignDeath(unit) then
        return settings.general.STATUS_DEAD
    end

    return nil
end


--[[ Evaluate a unit's level and color the returned string accordingly.

  STRING assessTargetLevel()
  :param: level INT - The level of the unit.
]]
local assessTargetLevel = function(level)
    if level < 0 then
        return format("|cff%s%s|r", settings.colors.targetLevel["danger"], "??")
    end

    if level < settings.general.questGreenLevel then
        return format("|cff%s%d|r", settings.colors.targetLevel["trivial"], level)
    end

    local difference = level - settings.general.playerLevel
    if difference > 4 then
        return format("|cff%s%d|r", settings.colors.targetLevel["hard"], level)
    elseif difference > 2 then
        return format("|cff%s%d|r", settings.colors.targetLevel["medium"], level)
    elseif difference > -3 then
        return format("|cff%s%d|r", settings.colors.targetLevel["normal"], level)
    elseif difference > -6 then
        return format("|cff%s%d|r", settings.colors.targetLevel["easy"], level)
    else
        return format("|cff%s%d|r", settings.colors.targetLevel["danger"], level)
    end
end


--[[ Trigger the correct UnitFrame menu. Applied as click-handler.
]]
cb.ufMenuTrigger = function(self)
    local unit = self.unit:sub(1, -2)
    local cunit = self.unit:gsub('(.)', string.upper, 1)

    if(unit == 'party' or unit == 'partypet') then
        ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor', 0, 0)
    elseif(_G[cunit..'FrameDropDown']) then
        ToggleDropDownMenu(1, nil, _G[cunit..'FrameDropDown'], 'cursor', 0, 0)
    end
end


--[[ Update the name of a unit.

  VOID updateName()
  :param: self TABLE - The actual unitframe, handled by oUF.
  :param: event STRING - The function will be called with the event, but that
                         parameter is not actually used!

  The unitframes are setup to have a fixed width for the ``self.Name`` text
  object with truncation activated. So if the actual name is too long, it will
  get adjusted automatically.
]]
cb.updateName = function(self, event)
    local name = UnitName(self.unit)
    if name then
        self.Name:SetFormattedText("|cff%s%s|r", settings.colors["name"], name)
    end
end


--[[ Update the name of the *target* unit.

  VOID updateNameTarget()
  :param: self TABLE - The actual unitframe, handled by oUF.
  :param: event STRING - The function will be called with the event, but that
                         parameter is not actually used!

  This is a dedicated function for the *target* unitframe, as this is the only
  one which includes the target's level. The ``level`` part will be colored
  by ``assessTargetLevel()`` and the corresponding settings.
]]
cb.updateNameTarget = function(self, event)
    local name = UnitName(self.unit)
    if name then
        self.Name:SetFormattedText("%s |cff%s%s|r", assessTargetLevel(UnitLevel(self.unit)), settings.colors["name"], name)
    end
end


--[[ DO NOT update the name.

  This callback does nothing. It can only be applied in unitframes, that don't
  show the Name text (e.g. player).
]]
cb.updateNameNoop = function(self, event)
    return
end


--[[ Provide a unit's health value as percent or the max value.

  VOID updateHealthPercent()
  :param: health FRAME - The corresponding element of the unitframe
  :param: unit STRING - The unit
  :param: min INT - The current health value
  :param: max INT - The maximum health value for that unit
]]
cb.updateHealthPercent = function(health, unit, min, max)
    if not unit then
        return
    end

    local statusString = getStatusString(unit)
    if statusString then
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, statusString)
        health:GetParent():UNIT_NAME_UPDATE(nil, unit)
        return
    end

    if ( min ~= max ) then
        health.value:SetFormattedText("|cff%s%.0f%%|r", settings.colors.hpDeficit, (min/max)*100)
    else
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, min)
    end

    health:GetParent():UNIT_NAME_UPDATE(nil, unit)
end


--[[ Provide a unit's health value as defcit from its max or the max value.

  VOID updateHealthDeficit()
  :param: health FRAME - The corresponding element of the unitframe
  :param: unit STRING - The unit
  :param: min INT - The current health value
  :param: max INT - The maximum health value for that unit
]]
cb.updateHealthDeficit = function(health, unit, min, max)
    if not unit then
        return
    end

    local statusString = getStatusString(unit)
    if statusString then
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, statusString)
        health:GetParent():UNIT_NAME_UPDATE(nil, unit)
        return
    end

    if ( min ~= max ) then
        health.value:SetFormattedText("|cff%s-%s|r", settings.colors.hpDeficit, (max-min))
    else
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, min)
    end

    health:GetParent():UNIT_NAME_UPDATE(nil, unit)
end


--[[ How to update a unit's health value.

  This acts like a *pointer* to an actual function (e.g.
  ``updateHealthPercent()`` / ``updateHealthDeficit()``. It is used inside of
  ``updateHealth_replaceName()``, which is the default function for most
  unitframes.

  The idea is, to switch between different *actual* implementations, depending
  on the player's role, implementing a *healer mode*.
]]
cb.updateHealth = cb.updateHealthPercent


--[[ Update the unit's health and show/hide it in combination with the name.

  VOID updateHealth()
  :param: health FRAME - The corresponding element of the unitframe
  :param: unit STRING - The unit
  :param: min INT - The current health value
  :param: max INT - The maximum health value for that unit

  Most unitframes show **either** the unit's name or its health value. This
  function takes care of switching those by hiding/showing the desired text
  object (``self.Name`` or ``self.Health.value``).

  **HOW** the health is presented, is dependent on ``cb.updateHealth``, which
  can point to ``updateHealthPercent()`` or ``updateHealthDeficit()``.
]]
cb.updateHealth_replaceName = function(health, unit, min, max)
    if not unit then
        return
    end

    cb.updateHealth(health, unit, min, max)

    local name = health:GetParent().Name
    if min ~= max then
        health.value:Show()
        name:Hide()
    else
        health.value:Hide()
        name:Show()
    end
end


--[[ Update the health on the player's frame.

  VOID updateHealth_player()
  :param: health FRAME - The corresponding element of the unitframe
  :param: unit STRING - The unit
  :param: min INT - The current health value
  :param: max INT - The maximum health value for that unit

  The player's frame requires a health string in the format ``current|percent``
  and should provide support for hunter's *Feign Death* ability. This function
  does not trigger a name update (because the player's unitframe doesn't show
  a name).
]]
cb.updateHealth_player = function(health, unit, min, max)
    if not unit then
        return
    end

    -- TODO: Is this the correct ID of hunter's "Feign Death"?
    local isFeign = C_UnitAuras.GetPlayerAuraBySpellID(5384) ~= nil
    if UnitIsDead(unit) and not isFeign then
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, settings.general.STATUS_DEAD)
        return
    end

    if max == 0 then
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpDeficit, "???")
        return
    end

    local percentHp = (min / max) * 100

    if percentHp < 100 then
        health.value:SetFormattedText("|cff%s%s l |r|cff%s%.0f%%|r", settings.colors.hpValue, min, settings.colors.hpDeficit, percentHp)
    else
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, min)
    end
end


--[[ Update the health on the target's frame.

  VOID updateHealth_target()
  :param: health FRAME - The corresponding element of the unitframe
  :param: unit STRING - The unit
  :param: min INT - The current health value
  :param: max INT - The maximum health value for that unit

  The target's frame requires a health string in the format ``percent|current``.
]]
cb.updateHealth_target = function(health, unit, min, max)
    if not unit then
        return
    end

    local statusString = getStatusString(unit)
    if statusString then
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, statusString)
        health:GetParent():UNIT_NAME_UPDATE(nil, unit)
        return
    end

    if max == 0 then
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpDeficit, "???")
    end

    local percentHp = (min / max) * 100

    if percentHp < 100 then
        health.value:SetFormattedText("|cff%s%.0f%%|r|cff%s l %s|r", settings.colors.hpDeficit, percentHp, settings.colors.hpValue, min)
    else
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, min)
    end

    health:GetParent():UNIT_NAME_UPDATE(nil, unit)
end


local filterAuraAllow = function(spellId, auraList)
    return auraList[spellId]
end


local filterAuraBan = function(spellId, auraList)
    return not auraList[spellId]
end


-- cb.filterBuffsPlayer = function(element, unit, button, aura, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod)
cb.filterBuffsAllow = function(_, unit, _, _, _, _, _, _, _, _, _, _, _, spellId)
    -- return filterAuraAllow(spellId, PredatorUnitFramesSettings.player.buffList)
    return filterAuraAllow(spellId, PredatorUnitFramesSettings[unit]["buffList"])
end


cb.filterBuffsBan = function(_, unit, _, _, _, _, _, _, _, _, _, _, _, spellId)
    -- return filterAuraBan(spellId, PredatorUnitFramesSettings.player.buffList)
    return filterAuraBan(spellId, PredatorUnitFramesSettings[unit]["buffList"])
end


cb.filterDebuffsAllow = function(_, unit, _, _, _, _, _, _, _, _, _, _, _, spellId)
    return filterAuraAllow(spellId, PredatorUnitFramesSettings[unit]["debuffList"])
end


cb.filterDebuffsBan = function(_, unit, _, _, _, _, _, _, _, _, _, _, _, spellId)
    return filterAuraBan(spellId, PredatorUnitFramesSettings[unit]["debuffList"])
end

-- Attach to the addon's namespace
ns.callbacks = cb
