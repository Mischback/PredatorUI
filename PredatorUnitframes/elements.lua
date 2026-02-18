--[[
]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...

-- Grab other modules of *this* addon
local settings = ns.settings
local util = ns.util
local callbacks = ns.callbacks

local elements = {}

local FRAMELEVEL = {
    ["health"] = 20,
    ["castbar"] = 30,
    ["eyecandy"] = 40,
    ["power"] = 50,
}


--[[ BASE FRAME

  This is the most generic and stripped down unit frame. It only provides
  a health-bar (including text-based value and a setup to visualize incoming
  heals), a power-bar (without text-based value) and a text-based name of the
  unit.
]]
elements.createBaseFrame = function(self, width, height, hpFontSize, nameFontSize)
    self:SetSize(width, height)

    -- HEALTH BAR
    local hp = CreateFrame("StatusBar", nil, self)
    hp:SetAllPoints(self)
    hp:SetFrameLevel(FRAMELEVEL.health)
    hp:SetStatusBarTexture(settings.textures.bar, "BORDER")
    hp:SetStatusBarColor(unpack(settings.colors.hpBarFg))

    hp.bg = hp:CreateTexture(nil, "BACKGROUND")
    hp.bg:SetAllPoints(hp)
    hp.bg:SetTexture(settings.textures.solid)
    hp.bg:SetVertexColor(unpack(settings.colors.hpBarBg))

    self.Health = hp

    -- FIXME: Heal prediction is NOT working!
    local mhpb = CreateFrame("StatusBar", nil, self)
    mhpb:SetFrameLevel(FRAMELEVEL.health + 1)
    mhpb:SetPoint("TOPLEFT", hp:GetStatusBarTexture(), "TOPRIGHT")
    mhpb:SetPoint("BOTTOMLEFT", hp:GetStatusBarTexture(), "BOTTOMRIGHT")
    mhpb:SetWidth(width)
    mhpb:SetStatusBarTexture(settings.textures.bar, "BORDER")
    mhpb:SetStatusBarColor(unpack(settings.colors.hpMyHeal))
    mhpb:Hide()

    local ohpb = CreateFrame('StatusBar', nil, self)
    mhpb:SetFrameLevel(FRAMELEVEL.health + 1)
    ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT')
    ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT')
    ohpb:SetWidth(width)
    ohpb:SetStatusBarTexture(settings.textures.bar, 'BORDER')
    ohpb:SetStatusBarColor(unpack(settings.colors.hpHeal))
    ohpb:Hide()

    self.HealPrediction = {
        ["myBar"] = mhpb,
        ["otherBar"] = ohpb,
        ["maxOverflow"] = 1.0,
    }

    -- POWER
    local pb = CreateFrame("StatusBar", nil, self)
    pb:SetFrameLevel(FRAMELEVEL.power)
    pb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 10, 4)
    pb:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -10, -3)
    pb:SetStatusBarTexture(settings.textures.bar2, "BORDER")

    pb.bg = pb:CreateTexture(nil, "BACKGROUND")
    pb.bg:SetAllPoints(pb)
    pb.bg:SetTexture(settings.textures.solid)
    pb.bg:SetVertexColor(unpack(settings.colors.hpBarFg))

    pb.colorTapping = true
    pb.colorDisconnected = true
    pb.colorClass = true
    pb.colorClassPet = true
    pb.colorReaction = true

    self.Power = pb

    -- TEXT
    self.Health.value = util.createFontObject(self.Health, hpFontSize, settings.fonts["hp"])
    self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 2, 1)
    self.Health.value:SetJustifyH("CENTER")

    self.Name = util.createFontObject(self.Health, nameFontSize, settings.fonts["hp"])
    self.Name:SetPoint("CENTER", self.Health, "CENTER", 1, 1)
    self.Name:SetJustifyH("CENTER")

    -- EYE CANDY
    self.eyecandy = CreateFrame("FRAME", nil, self)
    self.eyecandy:SetFrameLevel(FRAMELEVEL.eyecandy)
    self.eyecandy:SetAllPoints(self.Health)
    util.applyGloss(self.eyecandy, (hp:GetHeight()/3)*2)
    util.applyBorder(self.eyecandy)
    util.applyBorder(pb)

    -- CALLBACKS
    self.menu = callbacks.ufMenuTrigger
    self:RegisterForClicks("anyup")
    self:SetAttribute("*type2", "togglemenu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    self.Health.PostUpdate = callbacks.updateHealth_percent_visibility
    self.UNIT_NAME_UPDATE = callbacks.updateName
end


--[[ CASTBAR

  This is the default implementation of a castbar. It is attached to the
  unitframe's Health-bar (and covers that one!).

  FIXME: ALL colors need a dedicated look!
]]
elements.createCastbar = function(self)
    local iconSize, textSize, timeSize = 12, 12, 10
    if self:GetHeight() > 32 then
        iconSize = 20
        textSize = 14
        timeSize = 12
    end

    local cb = CreateFrame("STATUSBAR", nil, self)
    cb:SetStatusBarTexture(settings.textures.bar, "ARTWORK")
    cb:SetStatusBarColor(unpack(settings.colors.castbarGeneric))

    cb.bg = cb:CreateTexture(nil, "BACKGROUND")
    cb.bg:SetAllPoints(cb)
    cb.bg:SetTexture(settings.textures.solid)
    cb.bg:SetVertexColor(unpack(settings.colors.hpBarFg))

    cb:SetAllPoints(self.Health)
    cb:SetFrameLevel(FRAMELEVEL.castbar)

    cb.SafeZone = cb:CreateTexture(nil, "BORDER")
    cb.SafeZone:SetPoint("TOPRIGHT")
    cb.SafeZone:SetPoint("BOTTOMRIGHT")
    cb.SafeZone:SetTexture(settings.textures.solid)
    cb.SafeZone:SetVertexColor(0.69, 0.31, 0.31)

    cb.Icon = cb:CreateTexture(nil, "OVERLAY")
    cb.Icon:SetHeight(iconSize)
    cb.Icon:SetWidth(iconSize)
    cb.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    cb.Icon:SetPoint("LEFT", cb, "LEFT", 4, 2)

    cb.Text = util.createFontObject(cb, textSize, settings.fonts.details)
    cb.Text:SetPoint("LEFT", cb.Icon, "RIGHT", 1, -1)
    cb.Text:SetTextColor(0.84, 0.75, 0.65)

    cb.Time = util.createFontObject(cb, timeSize, settings.fonts.details)
    cb.Time:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", -2, 2)
    cb.Time:SetTextColor(0.84, 0.75, 0.65)
    cb.Time:SetJustifyH("RIGHT")

    return cb
end


elements.styleAura = function(frame, btn)
    btn.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    util.applyBorder(btn)
end


-- Attach to the addon's namespace
ns.elements = elements
