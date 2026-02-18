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

-- Grab other modules of *this* addon
local settings = ns.settings
local util = ns.util  -- Luacheck: ignore (will be used later!)

local cb = {}


--[[ Determine of a unit is "dead" or "offline".
]]
local getStatusString = function(unit)
    if not UnitIsConnected(unit) then
        return settings.general.STATUS_OFFLINE
    end

    if UnitIsDead(unit) and not UnitIsFeignDeath(unit) then
    -- if UnitIsDead(unit) then
        return settings.general.STATUS_DEAD
    end

    return nil
end


--[[
    Trigger the correct UnitFrame menu. Applied as click-handler in
    CreateBaseUnitFrame.
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


cb.updateName = function(self, event)
    local name = UnitName(self.unit)
    if name then
        self.Name:SetFormattedText("|cff%s%s|r", settings.colors["name"], name)
    end
end


--[[ DO NOT update the name.

  This callback does nothing. It can only be applied in unitframes, that don't
  show the Name text (e.g. player).
]]
cb.updateNameNoop = function(self, event)
    return
end


cb.updateHealth_percent = function(health, unit, min, max)
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


cb.updateHealth_percent_visibility = function(health, unit, min, max)
    if not unit then
        return
    end

    cb.updateHealth_percent(health, unit, min, max)

    local name = health:GetParent().Name
    if min ~= max then
        health.value:Show()
        name:Hide()
    else
        health.value:Hide()
        name:Show()
    end
end


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
    end

    local percentHp = (min / max) * 100

    if percentHp < 100 then
        health.value:SetFormattedText("|cff%s%s l |r|cff%s%.0f%%|r", settings.colors.hpValue, min, settings.colors.hpDeficit, percentHp)
    else
        health.value:SetFormattedText("|cff%s%s|r", settings.colors.hpValue, min)
    end
end


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


-- Attach to the addon's namespace
ns.callbacks = cb
