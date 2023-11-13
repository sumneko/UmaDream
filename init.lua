local umaDream = sgs.Package("马娘梦", sgs.Package_GeneralPack)

local originRequire = require

---@param name string
---@return any
function require(name)
    return originRequire('UmaDream.' .. name)
end

---@class UmaDream
UD = {}

Class = require 'tools.class'.declare
New   = require 'tools.class'.new

---@class Uma
---@field name string
---@field hp integer
---@overload fun(name: string, hp: integer): Uma
local Uma = Class 'Uma'

function Uma:__init(name, hp)
    self.name = name
    self.hp = hp
end

---@param uma Uma
local function registerUma(uma)
    local general = sgs.General(umaDream, uma.name, '马娘', uma.hp, true, false, false)
end

registerUma(require 'umas.hongxiao')
registerUma(require 'umas.miemie')

return { umaDream }
