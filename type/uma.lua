---@class Uma
---@field private handle sgs.General
---@overload fun(name: string, data: Uma.Data): Uma
local Uma = Class 'Uma'

---@class Uma.Data
---@field hp integer
---@field desc? string
---@field skills? string[]

function Uma:__init(name, data)
    ---@type string
    self.name = name
    ---@type Uma.Data
    self.data = data
end

---@param package sgs.Package
---@return sgs.General
function Uma:register(package)
    if self.handle then
        return self.handle
    end
    local general = sgs.General(package, self.name, '马娘', self.data.hp, true, false, false)
    self.handle = general

    for _, skillName in ipairs(self.data.skills or {}) do
        local skill = UD.skillMap[skillName]
        if skill then
            general:addSkill(skill:instance())
        end
    end

    return general
end
