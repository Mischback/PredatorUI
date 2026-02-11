-- Provide addon-specific environment, don't work on global namespace
local _, ns = ...


-- ==============
-- LOCALIZE STUFF
-- ==============
-- Grab other modules of *this* addon
local settings = ns.settings

local core = {}


--[[ Debugging to ChatFrame
  VOID debugging(STRING text)
]]
core.debugging = function(text)
    DEFAULT_CHAT_FRAME:AddMessage('|cff79c947Predator|r|cffffffffMinimap|r: |cffeeeeee'..text..'|r')
end


ns.core = core
