package.path = package.path .. ';./extensions/UmaDream/?.lua'

local umaDream = sgs.Package("马娘梦", sgs.Package_GeneralPack)

---@class UmaDream
UD = {}

Class = require 'tools.class'.declare
New   = require 'tools.class'.new

require 'type.uma'
require 'type.skill'

require 'umas.hongxiao':register(umaDream)
require 'umas.miemie':register(umaDream)

return { umaDream }
