---@class Uma
---@field private handle sgs.General
---@overload fun(name: string, data: Uma.Data): Uma
local Uma = Class 'Uma'

---@type table<string, Uma>
Uma.map = {}

local uid = 0

---@class Uma.Data
---@field id string
---@field hp integer
---@field showName? string # 显示名，默认为名字
---@field title? string # 头衔
---@field designer? string # 设计师
---@field cv? string # 配音者
---@field illustrator? string # 画师
---@field skills? string[] # 拥有的技能名称

function Uma:__init(name, data)
    ---@type string
    self.name = name
    ---@type Uma.Data
    self.data = data
    uid = uid + 1
    ---@type integer
    self.uid = uid

    Uma.map[name] = self
end

---@param package sgs.Package
---@return sgs.General
function Uma:instance(package)
    if self.handle then
        return self.handle
    end
    local id = self.data.id
    local general = sgs.General(package, id, '马娘', self.data.hp, false, false, false)
    self.handle = general

    sgs.LoadTranslationTable {
        [id] = self.name,
        ["&" .. id] = self.data.showName,
        ["#" .. id] = self.data.title,
        ["designer:" .. id] = self.data.designer,
        ["cv:" .. id] = self.data.cv,
        ["illustrator:" .. id] = self.data.illustrator,
    }

    for _, skillName in ipairs(self.data.skills or {}) do
        local skill = Class 'Skill'.map[skillName]
        if skill then
            general:addSkill(skill:instance())
        end
    end

    return general
end
