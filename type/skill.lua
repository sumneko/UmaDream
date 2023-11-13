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

---@class Skill.Data
---@field type Skill.Type
---@field desc? string

---@class Skill.EventData
---@field event Skill.Event
---@field callback Skill.EventCallback
---@field sgsEvent integer
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
end

---@enum(key) Skill.Event
local skillEventMap = {
    ['伤害-结束'] = { sgs.DamageComplete, 'toDamage' },
}

---@alias Skill.EventCallback fun(skill: sgs.Skill, player: sgs.ServerPlayer, data: sgs.QVariant)

---@class Skill
---@field event fun(self: Skill, event: '伤害-结束', callback: fun(skill: sgs.Skill, player: sgs.ServerPlayer, damage: sgs.DamageStruct)): Skill

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
    ---@type table<integer, Skill.EventData>
    local eventDataMap = {}
    for i, eventData in ipairs(self.events) do
        events[i] = eventData.sgsEvent
        eventDataMap[eventData.sgsEvent] = eventData
    end

    local skill = sgs.CreateTriggerSkill {
        name = self.name,
        frequency = skillTypeMap[self.data.type],
        events = events,
        on_trigger = function (skill, event, player, data)
            local eventData = eventDataMap[event]
            if eventData then
                local triggerData = data[eventData.dataKey](data)
                return eventData(skill, player, triggerData)
            end
            return false
        end,
        can_trigger = function (skill, player)
            return player:hasSkill(skill:objectName())
        end,
    }

    self.handle = skill

    return skill
end
