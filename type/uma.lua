---@class Uma
---@overload fun(name: string, hp: integer): Uma
local Uma = Class 'Uma'

function Uma:__init(name, hp)
    ---@type string
    self.name = name
    ---@type integer
    self.hp = hp
    ---@type Skill[]
    self.skills = {}
end

---@param skill Skill
function Uma:addSkill(skill)
    self.skills[#self.skills+1] = skill
end

---@param package sgs.Package
---@return sgs.General
function Uma:register(package)
    local general = sgs.General(package, self.name, '马娘', self.hp, true, false, false)

    for _, skill in ipairs(self.skills) do
        general:addSkill(skill:register())
    end

    return general
end
