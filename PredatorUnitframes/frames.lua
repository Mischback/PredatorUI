--[[
]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...

-- Grab other modules of *this* addon
local settings = ns.settings
local util = ns.util
local callbacks = ns.callbacks
local elements = ns.elements

local frames = {}


frames.createPlayer = function(self)
    elements.createBaseFrame(self, 168, 36, 18, 14)

    -- move Health-value to the right
    self.Health.value:SetJustifyH("RIGHT")
    self.Health.value:ClearAllPoints()
    self.Health.value:SetPoint("RIGHT", self.Health, "RIGHT", -2, -3)

    -- adjust Power-bar (move behind health and offset)
    self.Power:SetFrameLevel(self.Health:GetFrameLevel()-5)
    self.Power:ClearAllPoints()
    self.Power:SetPoint("TOPLEFT", self, "LEFT", -8, 0)
    self.Power:SetPoint("BOTTOMRIGHT", self, "BOTTOM", 40, -8)

    -- MP5
    if settings.general.playerClass ~= "WARRIOR" and settings.general.playerClass ~= "ROGUE" then
        self.MP5 = elements.createMP5(self, self.Power)
    end

    self.Buffs = CreateFrame("FRAME", self:GetName().."Buffs", self)
    self.Buffs:SetHeight(24)
    self.Buffs:SetWidth(self:GetWidth())
    self.Buffs.size = 24
    self.Buffs.spacing = 7
    self.Buffs.num = 5
    self.Buffs.PostCreateButton = elements.styleAura
    self.Buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)

    self.Debuffs = CreateFrame("FRAME", self:GetName().."Debuffs", self)
    self.Debuffs:SetHeight(24)
    self.Debuffs:SetWidth(self:GetWidth())
    self.Debuffs.size = 24
    self.Debuffs.spacing = 7
    self.Debuffs.num = 5
    self.Debuffs.PostCreateButton = elements.styleAura
    self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 8)

    -- callbacks
    self.Health.PostUpdate = callbacks.updateHealth_player
    -- No Name on the player frame!
    self.Name:Hide()
    self.UNIT_NAME_UPDATE = callbacks.updateNameNoop

    if PredatorUnitFramesSettings.player.buffMode == settings.general.auraMode.allow then
        self.Buffs.CustomFilter = callbacks.filterBuffsAllow
    else
        self.Buffs.CustomFilter = callbacks.filterBuffsBan
    end

    if PredatorUnitFramesSettings.player.debuffMode == settings.general.auraMode.allow then
        self.Debuffs.CustomFilter = callbacks.filterDebuffsAllow
    else
        self.Debuffs.CustomFilter = callbacks.filterDebuffsBan
    end
end


--[[ TARGET

  The target frame is very specific and has a unique look in this layout.

  Notable features:
  - TODO: Insert stuff here
]]
frames.createTarget = function(self)
    elements.createBaseFrame(self, 168, 36, 18, 18)

    -- move Health-value to the left
    self.Health.value:SetJustifyH("LEFT")
    self.Health.value:ClearAllPoints()
    self.Health.value:SetPoint("LEFT", self.Health, "LEFT", 3, -3)

    -- adjust Power-bar (move behind health and offset)
    self.Power:SetFrameLevel(self.Health:GetFrameLevel()-5)
    self.Power:ClearAllPoints()
    self.Power:SetPoint("TOPLEFT", self, "CENTER", -40, 0)
    self.Power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 8, -8)

    -- move the Name to the top right corner
    self.Name:SetParent(self.eyecandy)
    self.Name:SetJustifyH("RIGHT")
    self.Name:ClearAllPoints()
    self.Name:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 8)

    self.Buffs = CreateFrame("FRAME", self:GetName().."Buffs", self)
    self.Buffs:SetHeight(24)
    self.Buffs:SetWidth(self:GetWidth())
    self.Buffs.size = 24
    self.Buffs.spacing = 5
    self.Buffs.num = 6
    self.Buffs.PostCreateButton = elements.styleAura
    self.Buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)

    self.Debuffs = CreateFrame("FRAME", self:GetName().."Debuffs", self)
    self.Debuffs:SetHeight(24)
    self.Debuffs:SetWidth(self:GetWidth())
    self.Debuffs.size = 24
    self.Debuffs.spacing = 5
    self.Debuffs.num = 6
    self.Debuffs.PostCreateButton = elements.styleAura
    self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 14)

    -- provide a castbar
    self.Castbar = elements.createCastbar(self)
    self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "LEFT", 5, 0)
    self.Castbar.Text:SetPoint("LEFT", self.Castbar.Icon, "RIGHT", 3, -1)

    -- callbacks
    self.Health.PostUpdate = callbacks.updateHealth_target
    self.UNIT_NAME_UPDATE = callbacks.updateNameTarget

    if PredatorUnitFramesSettings.target.buffMode == settings.general.auraMode.allow then
        self.Buffs.CustomFilter = callbacks.filterBuffsAllow
    else
        self.Buffs.CustomFilter = callbacks.filterBuffsBan
    end

    if PredatorUnitFramesSettings.target.debuffMode == settings.general.auraMode.allow then
        self.Debuffs.CustomFilter = callbacks.filterDebuffsAllow
    else
        self.Debuffs.CustomFilter = callbacks.filterDebuffsBan
    end
end


--[[ TARGETTARGET

  The target's target unitframe follows the general look'n'feel of the layout,
  but is slightly adjusted to match the *player* and *target* frames.
]]
frames.createTargetTarget = function(self)
    elements.createBaseFrame(self, 80, 36, 18, 18)

    -- align Health-value with player/target frame
    self.Health.value:SetJustifyH("CENTER")
    self.Health.value:ClearAllPoints()
    self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, -3)

    -- move the Name to the top (centered)
    self.Name:SetParent(self.eyecandy)
    self.Name:SetJustifyH("CENTER")
    self.Name:ClearAllPoints()
    self.Name:SetPoint("TOP", self, "TOP", 0, 8)

    -- callbacks
    self.Health.PostUpdate = callbacks.updateHealthPercent
end


--[[ PET

  The target's target unitframe follows the general look'n'feel of the layout,
  but is slightly adjusted to match the *player* and *target* frames.
]]
frames.createPet = function(self)
    elements.createBaseFrame(self, 80, 36, 18, 18)

    -- align Health-value with player/target frame
    self.Health.value:SetJustifyH("CENTER")
    self.Health.value:ClearAllPoints()
    self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, -3)

    -- move the Name to the top (centered)
    self.Name:SetParent(self.eyecandy)
    self.Name:SetJustifyH("CENTER")
    self.Name:ClearAllPoints()
    self.Name:SetPoint("TOP", self, "TOP", 0, 7)

    -- callbacks
    -- TODO: Should this be controllable with SavedVar (e.g. for hunters?)
    self.Health.PostUpdate = callbacks.updateHealthPercent
end


--[[ FOCUS

  Very basic setup, but with some slight adjustments, e.g. a castbar.
]]
frames.createFocus = function(self)
    elements.createBaseFrame(self, 80, 32, 18, 18)

    -- provide a castbar
    self.Castbar = elements.createCastbar(self)
    -- FIXME: Spell name (Castbar.Text) needs truncation!
end


--[[ PARTY

  Very basic setup. The unit's Name and Health-value share the same spot (Name
  will be hidden when the health is below max).

  NOTE: spacing of ``10`` between TOP and BOTTOM.
]]
frames.createPartyMember = function(self)
    elements.createBaseFrame(self, 72, 28, 14, 14)

    self.Debuffs = CreateFrame("FRAME", self:GetName().."Debuffs", self)
    self.Debuffs:SetHeight(24)
    self.Debuffs:SetWidth(24 * 3 + 14)
    self.Debuffs.size = 24
    self.Debuffs.spacing = 7
    self.Debuffs.num = 3
    self.Debuffs["growth-x"] = "LEFT"
    self.Debuffs.initialAnchor = "BOTTOMRIGHT"
    self.Debuffs.PostCreateButton = elements.styleAura
    self.Debuffs:SetPoint("RIGHT", self, "LEFT", -6, 0)
end


frames.createPlayerCastbarSimple = function(self)
    self:SetSize(192, 24)

    --[[
    local pb = CreateFrame("STATUSBAR", nil, self)
    pb:SetFrameLevel(30)
    pb:SetAllPoints(self)
    pb:SetStatusBarTexture(settings.textures.bar2, "BORDER")

    pb.bg = pb:CreateTexture(nil, "BACKGROUND")
    pb.bg:SetAllPoints(pb)
    pb.bg:SetTexture(settings.textures.solid)
    pb.bg:SetVertexColor(unpack(settings.colors.hpBarFg))

    pb.colorClass = true

    self.Power = pb
    ]]

    self.Castbar = elements.createCastbar(self)

    self.Castbar.Icon:ClearAllPoints()
    self.Castbar.Icon:SetSize(24, 24)
    self.Castbar.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)

    self.Castbar:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPRIGHT", 8, 0)
    self.Castbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

    self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 2, -1)

    self.eyecandyBar = CreateFrame("FRAME", nil, self.Castbar)
    self.eyecandyBar:SetFrameLevel(40)
    self.eyecandyBar:SetAllPoints(self.Castbar)
    util.applyGloss(self.eyecandyBar, (self:GetHeight()/3)*2)
    util.applyBorder(self.eyecandyBar)

    self.eyecandyIcon = CreateFrame("FRAME", nil, self.Castbar)
    self.eyecandyIcon:SetFrameLevel(40)
    self.eyecandyIcon:SetAllPoints(self.Castbar.Icon)
    util.applyGloss(self.eyecandyIcon, (self:GetHeight()/3)*2)
    util.applyBorder(self.eyecandyIcon)
end


-- Attach to the addon's namespace
ns.frames = frames
