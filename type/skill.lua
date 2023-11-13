---@enum(key) Skill.Type
local skillTypeMap = {
    ['主动'] = sgs.Skill_NotFrequent,
    ['自动'] = sgs.Skill_Frequent,
    ['被动'] = sgs.Skill_Compulsory,
}

---@class Skill
---@field name string
---@field type Skill.Type
---@overload fun(name: string, type: Skill.Type): Skill
local Skill = Class 'Skill'

---@param name string
---@param type Skill.Type
function Skill:__init(name, type)
    self.name = name
    self.type = type
    ---@type {event: string, callback: Skill.EventCallback}[]
    self.events = {}
end

---@enum(key) Skill.Event
local skillEventMap = {
    ['伤害-结束'] = sgs.DamageComplete,
}

---@alias Skill.EventCallback fun(self: sgs.Skill, player: sgs.ServerPlayer, data: sgs.QVariant)

---@param event Skill.Event
---@param callback Skill.EventCallback
function Skill:event(event, callback)
    self.events[#self.events+1] = {
        event = event,
        callback = callback,
    }
end

---@return sgs.Skill
function Skill:register()
    local events = {}
    local eventCallbackMap = {}
    for i, eventData in ipairs(self.events) do
        events[i] = eventData.event
        eventCallbackMap[eventData.event] = eventData.callback
    end

    local skill = sgs.CreateTriggerSkill {
        name = self.name,
        frequency = skillTypeMap[self.type],
        events = events,
        on_trigger = function (self, event, player, data)
            local callback = eventCallbackMap[event]
            if callback then
                return callback(self, player, data)
            end
            return false
        end,
        can_trigger = function (self, player)
            return player:hasSkill(self:objectName())
        end,
    }

    return skill
end
