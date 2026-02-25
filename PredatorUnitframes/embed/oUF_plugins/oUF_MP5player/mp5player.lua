--[[ Provide a visual indicator for mana regen.

  Mana regen kicks in after a spell completed, with a 5 second delay. This
  plugin shows this delay and visualizes the time between regen ticks.

  It works only for the player's unitframe and requires a dedicated setup (or
  specific elements) on that frame.

  .MP5 - A statusbar
  .MP5.Spark - A texture which is attached to the right edge of the statusbar's
               texture, e.g. ``SetPoint("RIGHT", MP5:GetStatusBarTexture())``

  This plugin works by setting values on the statusbar, shifting the *Spark*
  position automatically.
]]


-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...

-- Get a reference to oUF
-- TODO: This only works for the embedded setup. Must be modified if this plugin
--       is deployed in a different structure.
local oUF = ns.oUF


-- CONSTANTS
local MP5_DELAY = 5  -- Seconds until Mana Regen kicks in
local MP5_TICK = 2  -- Seconds for one Mana Regen tick
local MP5_UPDATE_FREQUENCY = 0.05  -- Seconds between update of the bar
local POWER_TYPE_MANA = 0  -- Index of MANA while accessing ``UnitPower()``

-- INTERNAL VARIABLES
local currentPowerValue = 0
local timestampLastTick = 0
local timestampMP5Start = nil

local GetSpellPowerCost = GetSpellPowerCost
local GetTime = GetTime
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax


--[[ Determine if a cast consumed mana.

  VOID castCompleted()
  :param: spellID INT - The (just finished) spell's ID

  Only a spell that actually consumed mana will reset the mana regen or -
  the other way around - a free cast will not reset the mana regen.

  We calculate the (internal) timestamp, when regen kicks in again
  (``timestampMP5Start``) and store it in a module-specific variable.
]]
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


--[[ Track changes to the player's mana.

  VOID updateUnitPower()

  If it's a positive change, we store the timestamp of that tick in a
  module-specific variable (``timestampLastTick``).

  Please note: Consuming a mana potion messes with the next iteration of the
  regen cycle!
]]
local updateUnitPower = function()
    local powerValue = UnitPower("player", POWER_TYPE_MANA)
    if powerValue > currentPowerValue then
        timestampLastTick = GetTime()
    end

    currentPowerValue = powerValue
end


--[[ Disable this plugin.

  BOOL disableMP5()
  :param: self - The unitframe (handled by oUF)

  Unregister the event handlers, basically.
  The ``enableMP5()`` should ensure, that nothing fuzzy is done to any frame
  without the proper setup in the layout. However, this function will do
  cleanup.
]]
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


--[[ Update the actual bar value.

  VOID updateMP5()
  :param: self - The unitframe (handled by oUF)
  :param: elapsed INT - Time since this function was called the last time

  The actual core function. It determines if regen is currently running and
  visualize either the cooldown period until regen kicks in (taking 5 seconds
  after the last successful spell cast) or the period until the next regen
  tick (roughly 2 seconds).

  Hides the visualization if the player is at full mana.

  This function is applied as an OnUpdate script, so it must be as efficient
  as possible!
]]
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


--[[ Enable this plugin.

  BOOL enableMP5()
  :param: self - The unitframe (handled by oUF)
  :param: unit STRING - provided by oUF

  Initializes the visualization and some internal variables and sets up the
  event handlers and update scripts.
]]
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
