---@class Uma
---@field private handle sgs.General
---@overload fun(name: string, data: Uma.Data): Uma
local Uma = Class 'Uma'

---@type table<string, Uma>
Uma.map = {}

local uid = 0

---@class Uma.Data
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
    local name = ('Uma_%03d'):format(self.uid)
    local general = sgs.General(package, name, '马娘', self.data.hp, true, false, false)
    self.handle = general

    sgs.LoadTranslationTable {
        [name] = self.name,
        ["&" .. name] = self.data.showName,
        ["#" .. name] = self.data.title,
        ["designer:" .. name] = self.data.designer,
        ["cv:" .. name] = self.data.cv,
        ["illustrator:" .. name] = self.data.illustrator,
    }

    for _, skillName in ipairs(self.data.skills or {}) do
        local skill = Class 'Skill'.map[skillName]
        if skill then
            general:addSkill(skill:instance())
        end
    end

    return general
end
