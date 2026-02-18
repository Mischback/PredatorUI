--[[
  Provide non-specific utility functions.

  TODO: Some of these might even be applicable to other addons, outside of this
        layout. So they might be externalized even further.
]]

-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...

-- Grab other modules of *this* addon
local settings = ns.settings

local util = {}


-- ==============
-- LOCALIZE STUFF
-- ==============
local ipairs = ipairs
local unpack = unpack


--[[
  Create a generic font object.
]]
util.createFontObject = function(parent, size, font)
    local fo = parent:CreateFontString(nil, "OVERLAY")
    fo:SetFont(font, size, "OUTLINE")
    fo:SetJustifyH("CENTER")
    -- fo:SetShadowColor(0, 0, 0)
    -- fo:SetShadowOffset(1, 1)
    return fo
end


util.setBorderColor = function(self, r, g, b)
    if not self or type(self) ~= "table" then
        return
    end

    if not self.borderTextures then
        util.applyBorder(self)
    end

    if not r then
        -- r, g, b = 0.5, 0.5, 0.5
        r, g, b = unpack(settings.colors.borderDefault)
    end

    for _, tex in ipairs(self.borderTextures) do
        tex:SetVertexColor(r, g, b)
    end
end


util.applyBorder = function(frame, size)
    if not frame or type(frame) ~= "table" or frame.borderTextures then
        return
    end

    if not size then
        size = settings.general.borderWidth
    end

    local tex = {}
    local i

    for i = 1, 8 do
        tex[i] = frame:CreateTexture(nil, "OVERLAY")
        tex[i]:SetTexture(settings.textures.border)
        tex[i]:SetWidth(size)
        tex[i]:SetHeight(size)
    end

    local adjust = size / 2 - 6

    tex[1].id = "TOPLEFT"
    tex[1]:SetTexCoord(0, 1/3, 0, 1/3)
    tex[1]:SetPoint("TOPLEFT", frame, -5 - adjust, 5 + adjust)

    tex[2].id = "TOPRIGHT"
    tex[2]:SetTexCoord(2/3, 1, 0, 1/3)
    tex[2]:SetPoint("TOPRIGHT", frame, 5 + adjust, 5 + adjust)

    tex[3].id = "TOP"
    tex[3]:SetTexCoord(1/3, 2/3, 0, 1/3)
    tex[3]:SetPoint("TOPLEFT", tex[1], "TOPRIGHT")
    tex[3]:SetPoint("TOPRIGHT", tex[2], "TOPLEFT")

    tex[4].id = "BOTTOMLEFT"
    tex[4]:SetTexCoord(0, 1/3, 2/3, 1)
    tex[4]:SetPoint("BOTTOMLEFT", frame, -5 - adjust, -5 - adjust)

    tex[5].id = "BOTTOMRIGHT"
    tex[5]:SetTexCoord(2/3, 1, 2/3, 1)
    tex[5]:SetPoint("BOTTOMRIGHT", frame, 5 + adjust, -5 - adjust)

    tex[6].id = "BOTTOM"
    tex[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
    tex[6]:SetPoint("BOTTOMLEFT", tex[4], "BOTTOMRIGHT")
    tex[6]:SetPoint("BOTTOMRIGHT", tex[5], "BOTTOMLEFT")

    tex[7].id = "LEFT"
    tex[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
    tex[7]:SetPoint("TOPLEFT", tex[1], "BOTTOMLEFT")
    tex[7]:SetPoint("BOTTOMLEFT", tex[4], "TOPLEFT")

    tex[8].id = "RIGHT"
    tex[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
    tex[8]:SetPoint("TOPRIGHT", tex[2], "BOTTOMRIGHT")
    tex[8]:SetPoint("BOTTOMRIGHT", tex[5], "TOPRIGHT")

    frame.borderTextures = tex
    frame.SetBorderColor = util.setBorderColor

    util.setBorderColor(frame)
end


--[[
  Create a "glossy" overlay.

  FIXME: layout-specific, probably not right here! Might be moved to elements.lua
]]
util.applyGloss = function(frame, height)
    if not frame or type(frame) ~= "table" or frame.glossTextures then
        return
    end

    if not height then
        height = frame:GetHeight()
    end

    local gloss = {}

    gloss.left = frame:CreateTexture(nil, "ARTWORK")
    gloss.left:SetSize(13, height)
    gloss.left:SetTexture(settings.textures.gloss)
    gloss.left:SetTexCoord(0, 0.25, 0, 1)
    gloss.left:SetVertexColor(1, 1, 1, settings.colors.glossIntensity)
    gloss.left:SetPoint("TOPLEFT")

    gloss.right = frame:CreateTexture(nil, "ARTWORK")
    gloss.right:SetSize(13, height)
    gloss.right:SetTexture(settings.textures.gloss)
    gloss.right:SetTexCoord(0.75, 1, 0, 1)
    gloss.right:SetVertexColor(1, 1, 1, settings.colors.glossIntensity)
    gloss.right:SetPoint("TOPRIGHT")

    gloss.mid = frame:CreateTexture(nil, "ARTWORK")
    gloss.mid:SetHeight(height)
    gloss.mid:SetTexture(settings.textures.gloss)
    gloss.mid:SetTexCoord(0.25, 0.75, 0, 1)
    gloss.mid:SetVertexColor(1, 1, 1, settings.colors.glossIntensity)
    gloss.mid:SetPoint('TOPLEFT', gloss.left, 'TOPRIGHT')
    gloss.mid:SetPoint('TOPRIGHT', gloss.right, 'TOPLEFT')

    frame.glossTextures = gloss
end


-- Attach to the addon's namespace
ns.util = util
