-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...

-- Get a reference to oUF
local oUF = ns.oUF


-- CONSTANTS
local MP5_DELAY = 5  -- Seconds until Mana Regen kicks in
local MP5_TICK = 2  -- Seconds for one Mana Regen tick
local MP5_UPDATE_FREQUENCY = 0.05  -- Seconds between update of the bar
local POWER_TYPE_MANA = 0  -- Index of MANA while accessing ``UnitPower()``

local currentPowerValue = 0
local timestampLastTick = 0
local timestampMP5Start = nil


local castCompleted = function(_, _, _, _, spellID)
    local resetMP5 = false
    local spellCosts = GetSpellPowerCost(spellID)

    if spellCosts[1].cost > 0 or spellCosts[1].minCost > 0 or spellCosts[1].costPercent > 0 then
        resetMP5 = true
    end

    if not resetMP5 then
        return
    end

    timestampMP5Start = GetTime() + MP5_DELAY
end


local updateUnitPower = function()
    local powerValue = UnitPower("player", POWER_TYPE_MANA)
    if powerValue > currentPowerValue then
        timestampLastTick = GetTime()
    end

    currentPowerValue = powerValue
end


local disableMP5 = function(self)
    if not self then
        return false
    end

    local mp5 = self.MP5
    if not mp5 then
        return
    end

    self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", castCompleted)
    self:UnregisterEvent("UNIT_POWER_UPDATE", updateUnitPower)
    mp5.Spark:Hide()
    mp5:SetScript("OnUpdate", nil)

    return false
end

local updateMP5 = function(self, elapsed)
    local mp5 = self.MP5
    mp5.deltaLastUpdate = mp5.deltaLastUpdate + (tonumber(elapsed) or 0)

    if mp5.deltaLastUpdate > MP5_UPDATE_FREQUENCY then
        local powerValue = UnitPower("player", POWER_TYPE_MANA)
        local timestampNow = GetTime()

        if powerValue >= mp5.maxPower then
            mp5.Spark:Hide()
            mp5:SetValue(0)
            return
        end

        if timestampMP5Start and timestampMP5Start < timestampNow then
            timestampMP5Start = nil
            timestampLastTick = timestampNow
        end

        if timestampMP5Start then
            mp5:SetMinMaxValues(0, MP5_DELAY)
            mp5.Spark:Show()
            mp5:SetValue(timestampMP5Start - timestampNow)
        else
            mp5:SetMinMaxValues(0, MP5_TICK)
            mp5.Spark:Show()
            mp5:SetValue(timestampNow - timestampLastTick)
        end
    end
end


local enableMP5 = function(self, unit)
    if unit ~= "player" then
        disableMP5(self)
        return false
    end

    local mp5 = self.MP5
    if not mp5 then
        disableMP5(self)
        return false
    end

    mp5:SetValue(4)
    mp5.__owner = self

    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", castCompleted)
    self:RegisterEvent("UNIT_POWER_UPDATE", updateUnitPower)

    mp5.deltaLastUpdate = 0
    mp5.maxPower = UnitPowerMax("player", POWER_TYPE_MANA)
    mp5.Spark:SetPoint("CENTER", mp5:GetStatusBarTexture(), "RIGHT")

    mp5:SetScript("OnUpdate", function(_, elapsed) updateMP5(self, elapsed) end)

    return true
end


-- register with oUF
oUF:AddElement("MP5player", updateMP5, enableMP5, disableMP5)
