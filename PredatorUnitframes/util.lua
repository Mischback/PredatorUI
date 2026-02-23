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


--[[ Add a border to an element.

  VOID applyBorder()
  :param: frame FRAME - The element to add the border to
  :param: size INT - Override for the size.

  The implementation is provided in ``PredatorSharedMedia`` and used throughout
  all *Predator* addons.
]]
util.applyBorder = PredatorSharedMedia.applyBorder


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
