---@enum(key) Skill.Type
local skillTypeMap = {
    ['主动'] = sgs.Skill_NotFrequent,
    ['自动'] = sgs.Skill_Frequent,
    ['被动'] = sgs.Skill_Compulsory,
}

---@class Skill
---@field private handle sgs.Skill
---@overload fun(name: string, data: Skill.Data): Skill
local Skill = Class 'Skill'

---@type table<string, Skill>
Skill.map = {}

local uid = 0

---@class Skill.Data
---@field type Skill.Type
---@field desc? string

---@class Skill.EventData
---@field event Skill.Event
---@field callback Skill.EventCallback
---@field sgsEvent sgs.TriggerEvent
---@field dataKey string

---@param name string
---@param data Skill.Data
function Skill:__init(name, data)
    ---@type string
    self.name = name
    ---@type Skill.Data
    self.data = data
    ---@type Skill.EventData[]
    self.events = {}
    uid = uid + 1
    ---@type integer
    self.uid = uid

    Skill.map[name] = self
end

---@enum(key) Skill.Event
local skillEventMap = {
    ['伤害-造成后'] = { sgs.DamageCaused, 'toDamage' },
}

---@alias Skill.EventCallback fun(skill: sgs.Skill, player: sgs.ServerPlayer, data: sgs.QVariant)

---@class Skill
---@field event fun(self: Skill, event: '伤害-造成后', callback: fun(skill: sgs.Skill, player: sgs.ServerPlayer, damage: sgs.DamageStruct)): Skill

---@param event Skill.Event
---@param callback Skill.EventCallback
---@return self
function Skill:event(event, callback)
    self.events[#self.events+1] = {
        event = event,
        callback = callback,
        sgsEvent = skillEventMap[event][1],
        dataKey = skillEventMap[event][2],
    }
    return self
end

---@return sgs.Skill
function Skill:instance()
    if self.handle then
        return self.handle
    end
    local events = {}
    ---@type table<sgs.TriggerEvent, Skill.EventData>
    local eventDataMap = {}
    for i, eventData in ipairs(self.events) do
        events[i] = eventData.sgsEvent
        eventDataMap[eventData.sgsEvent] = eventData
    end
    print('skill instance!', self.name, UD.inspect(events))

    local name = ('UmaSkill_%03d'):format(self.uid)
    local skill = sgs.CreateTriggerSkill {
        name = name,
        global = true,
        frequency = skillTypeMap[self.data.type],
        events = events,
        on_trigger = function (skill, event, player, data)
            local eventData = eventDataMap[event]
            if eventData then
                local triggerData = data[eventData.dataKey](data)
                local suc, res = xpcall(eventData.callback, log.error, skill, player, triggerData)
                if suc then
                    return res
                end
            end
            return false
        end,
    }

    sgs.LoadTranslationTable {
        [name] = self.name,
        [':' .. name] = self.data.desc,
    }

    if not sgs.Sanguosha:getSkill(name) then
        sgs.SkillList():append(skill)
    end

    self.handle = skill

    return skill
end
