---@enum(key) Skill.Type
local skillTypeMap = {
    ['主动'] = 0,
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
---@field useOnce? boolean # 出牌阶段限一次
---@field global? boolean
---@field cost? integer # 需要消耗的手牌数
---@field costMin? integer # 最少需要消耗的手牌数

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
    ['伤害-造成前'] = { sgs.DamageInflicted, 'toDamage'},
    ['伤害-造成后'] = { sgs.Damage, 'toDamage' },
    ['阶段-开始']   = { sgs.EventPhaseStart, nil },
    ['卡牌-移动']   = {sgs.CardsMoveOneTime, 'toMoveOneTime'},
    ['主动-使用']   = { -1 },
    ['主动-条件']   = { -2 },
    ['主动-选牌']   = { -3 },
}

---@alias Skill.EventCallback fun(skill: sgs.Skill, player: sgs.ServerPlayer, context: sgs.QVariant)

---@class Skill
---@field event fun(self: Skill, event: '伤害-造成前', callback: fun(skill: sgs.Skill, player: sgs.ServerPlayer, context: sgs.QVariant, damage: sgs.DamageStruct): boolean?): Skill
---@field event fun(self: Skill, event: '伤害-造成后', callback: fun(skill: sgs.Skill, player: sgs.ServerPlayer, context: sgs.QVariant, damage: sgs.DamageStruct): boolean?): Skill
---@field event fun(self: Skill, event: '阶段-开始', callback: fun(skill: sgs.Skill, player: sgs.ServerPlayer, context: sgs.QVariant)): Skill
---@field event fun(self: Skill, event: '卡牌-移动', callback: fun(skill: sgs.Skill, player: sgs.ServerPlayer, context: sgs.QVariant, moveInfo: sgs.CardsMoveOneTimeStruct)): Skill
---@field event fun(self: Skill, event: '主动-使用', callback: fun(card: sgs.LuaSkillCard, source: sgs.ServerPlayer, targets: sgs.ServerPlayer[])): Skill
---@field event fun(self: Skill, event: '主动-选牌', callback: fun(source: sgs.Player, selected: sgs.Card[], toSelect: sgs.Card): boolean): Skill

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

---@private
---@return sgs.TriggerEvent[]
---@return table<sgs.TriggerEvent, function>
function Skill:compileEvents()
    ---@type sgs.TriggerEvent[]
    local events = {}
    ---@type table<sgs.TriggerEvent, Skill.EventData[]>
    local eventMap = {}

    for _, eventData in ipairs(self.events) do
        if not eventMap[eventData.sgsEvent] then
            if eventData.sgsEvent > 0 then
                events[#events+1] = eventData.sgsEvent
            end
            eventMap[eventData.sgsEvent] = {}
        end
        table.insert(eventMap[eventData.sgsEvent], eventData)
    end

    ---@type table<sgs.TriggerEvent, function>
    local callbackMap = {}
    for triggerEvent, eventDatas in pairs(eventMap) do
        local eventData = eventDatas[1]
        local key = eventData.dataKey
        if #eventDatas == 1 then
            callbackMap[triggerEvent] = function (skill, player, context)
                local triggerData = key and context[key](context)
                local suc, res = xpcall(eventData.callback, log.error, skill, player, context, triggerData)
                if suc ~= nil then
                    return res
                end
            end
        else
            local callbacks = {}
            for _, eData in ipairs(eventDatas) do
                callbacks[#callbacks+1] = eData.callback
            end
            callbackMap[eventData.sgsEvent] = function (skill, player, context)
                local triggerData = key and context[key](context)
                for _, callback in ipairs(callbacks) do
                    local suc, res = xpcall(callback, log.error, skill, player, context, triggerData)
                    if suc and res ~= nil then
                        return res
                    end
                end
            end
        end
    end

    return events, callbackMap
end

---@private
---@param name string
---@param callbackMap table<sgs.TriggerEvent, function>
---@return sgs.LuaSkillCard
function Skill:createDummySkillCard(name, callbackMap)
    local useCallback = callbackMap[skillEventMap['主动-使用'][1]]
    local filterCallback = callbackMap[skillEventMap['主动-选牌'][1]]
    local card = sgs.CreateSkillCard {
        name = name .. '_Card',
        skill_name = name,
        target_fixed = true,
        on_use = function (sgsCard, room, source, targets)
            if filterCallback then
                local subCards = sgsCard:getSubcards()
                local selected = {}
                for i = 1, subCards:length() - 1 do
                    local cardID = subCards:at(i)
                    local toSelectID = subCards:at(i + 1)
                    selected[i] = sgs.Sanguosha:getCard(cardID)
                    local toSelect = sgs.Sanguosha:getCard(toSelectID)
                    local suc, res = filterCallback(sgsCard, source, selected, toSelect)
                    if not suc or not res then
                        return
                    end
                end
            end
            if useCallback then
                xpcall(useCallback, log.error, sgsCard, source, targets)
            end
        end
    }
    return card
end

---@return sgs.Skill
function Skill:instance()
    if self.handle then
        return self.handle
    end
    local events, callbackMap = self:compileEvents()
    print('skill instance!', self.name, UD.inspect(events))

    local name = ('UmaSkill_%03d'):format(self.uid)
    local skill
    if self.data.type == '主动' then
        local card = self:createDummySkillCard(name, callbackMap)
        skill = sgs.CreateViewAsSkill {
            name = name,
            n = self.data.cost or 0,
            view_as = function (sgsSkill, cards)
                if #cards < (self.data.costMin or self.data.cost) then
                    return
                end
                local cardInstance = card:clone()
                for _, card in ipairs(cards) do
                    cardInstance:addSubcard(card)
                end
                return cardInstance
            end,
            view_filter = function(sgsSkill, selected, toSelect)
                if #selected >= (self.data.cost or 0) then
                    return false
                end
                if toSelect:isEquipped() then
                    return false
                end
                local callback = callbackMap[skillEventMap['主动-选牌'][1]]
                if callback then
                    local suc, res = xpcall(callback, log.error, sgs.Self, selected, toSelect)
                    return suc and res
                end
                return true
            end,
            enabled_at_play = function (sgsSkill, player)
                if not player:hasSkill(name) then
                    return false
                end
                if self.data.useOnce and player:hasUsed('#' .. card:objectName()) then
                    return false
                end
                return true
            end,
        }
    else
        skill = sgs.CreateTriggerSkill {
            name = name,
            global = self.data.global,
            frequency = skillTypeMap[self.data.type],
            events = events,
            on_trigger = function (sgsSkill, event, player, context)
                local callback = callbackMap[event]
                if callback then
                    return callback(skill, player, context)
                end
            end,
        }
    end

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
