package.path = package.path .. ';./extensions/UmaDream/?.lua'

local umaDream = sgs.Package("马娘梦", sgs.Package_GeneralPack)

---@class UmaDream
UD = {}

Class = require 'tools.class'.declare
New   = require 'tools.class'.new

require 'tools.log'
UD.inspect = require 'tools.inspect'
UD.util    = require 'tools.utility'

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
    config.kingdoms[#config.kingdoms+1] = 'uma'
    config.kingdom_colors['uma'] = '#ffcc00'
end

sgs.LoadTranslationTable {
    ['uma'] = '马娘',
}

require 'type.uma'
require 'type.skill'

require 'umas.hongxiao'
require 'umas.miemie'

for _, uma in UD.util.sortPairs(Class 'Uma'.map) do
    uma:instance(umaDream)
end
for _, skill in UD.util.sortPairs(Class 'Skill'.map) do
    skill:instance()
end

return { umaDream }
