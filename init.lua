package.path = package.path .. ';./extensions/UmaDream/?.lua'

local umaDream = sgs.Package("马娘梦", sgs.Package_GeneralPack)

---@class UmaDream
UD = {}

Class = require 'tools.class'.declare
New   = require 'tools.class'.new

-- 添加新势力
do
    require 'lua.config'
    ---@diagnostic disable-next-line: undefined-global
    local config = config
    config.kingdoms[#config.kingdoms+1] = '马娘'
    config.kingdom_colors['马娘'] = '#96943D'
end

require 'type.uma'
require 'type.skill'

---@type table<string, Uma>
UD.umaMap = {}

---@type table<string, Skill>
UD.skillMap = {}

---@param name string
---@param data Uma.Data
function UD.createUma(name, data)
    UD.umaMap[name] = New 'Uma' (name, data)
    return UD.umaMap[name]
end

---@param name string
---@param data Skill.Data
function UD.createSkill(name, data)
    UD.skillMap[name] = New 'Skill' (name, data)
    return UD.skillMap[name]
end

require 'umas.hongxiao'
require 'umas.miemie'

for _, uma in pairs(UD.umaMap) do
    uma:register(umaDream)
end
for _, skill in pairs(UD.skillMap) do
    skill:instance()
end

return { umaDream }
