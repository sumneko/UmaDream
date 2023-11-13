package.path = package.path .. ';./extensions/UmaDream/?.lua'

local umaDream = sgs.Package("马娘梦", sgs.Package_GeneralPack)

---@class UmaDream
UD = {}

Class = require 'tools.class'.declare
New   = require 'tools.class'.new

require 'tools.log'
UD.inspect = require 'tools.inspect'

---@class Log
log = New 'Log' {
    path = './extensions/UmaDream/log/test.log',
}

print = log.debug
log.info('你好马娘！')

-- 添加新势力
do
    require 'lua.config'
    ---@diagnostic disable-next-line: undefined-global
    local config = config
    config.kingdoms[#config.kingdoms+1] = '马娘'
    config.kingdom_colors['马娘'] = '#ffcc00'
end

require 'type.uma'
require 'type.skill'

---@param name string
---@param data Uma.Data
function UD.createUma(name, data)
    return New 'Uma' (name, data)
end

---@param name string
---@param data Skill.Data
function UD.createSkill(name, data)
    return New 'Skill' (name, data)
end

require 'umas.hongxiao'
--require 'umas.miemie'

for _, uma in pairs(Class 'Uma'.map) do
    uma:instance(umaDream)
end
for _, skill in pairs(Class 'Skill'.map) do
    skill:instance()
end

return { umaDream }
