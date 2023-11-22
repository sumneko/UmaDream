New 'Uma' ('虹ヶ咲I', {
    hp       = 6,
    title    = '🐷',
    designer = '最萌小汐',
    skills   = {'画🐽', '拍🐽', '发🐽'},
})

New 'Skill' ('画🐽', {
    type = '自动',
    desc = [[
你每造成1点伤害，对方获得1层“🐽”。
拥有“🐽”的玩家回合结束时流失1点体力，然后失去一层“🐽”。
拥有“🐽”的玩家对你造成的伤害-1，然后失去一层“🐽”。
]],
})
--你每造成1点伤害，对方获得1层“🐽”。
: event('伤害-造成后', function (skill, player, context, damage)
    if not player:hasSkill(skill:objectName()) then
        return
    end
    if not damage.from
    or damage.from == damage.to
    or damage.from ~= player then
        return
    end
    damage.to:gainMark('&zhubi', 1)
end)
--拥有“🐽”的玩家回合结束时流失1点体力，然后失去一层“🐽”。
: event('阶段-开始', function (skill, player, context)
    if player:getMark('&zhubi') == 0
    or player:getPhase() ~= sgs.Player_Finish then
        return
    end
    player:loseMark('&zhubi', 1)
    player:getRoom():loseHp(player, 1)
end)
--拥有“🐽”的玩家对你造成的伤害-1，然后失去一层“🐽”。
: event('伤害-造成前', function (skill, player, context, damage)
    if not damage.from
    or damage.to ~= player
    or not damage.to:hasSkill(skill:objectName())
    or damage.from:getMark('&zhubi') == 0
    or damage.damage <= 0 then
        return
    end
    damage.from:loseMark('&zhubi', 1)
    damage.damage = damage.damage - 1
    if damage.damage <= 0 then
        return true
    end
    context:setValue(damage)
end)

sgs.LoadTranslationTable {
    ['zhubi'] = '🐽',
}

New 'Skill' ('拍🐽', {
    type = '被动',
    desc = [[
回合结束时，场上每有一人拥有“🐽”，你抽一张牌。
]],
})
--回合结束时，场上每有一人拥有“🐽”，你抽一张牌。
: event('阶段-开始', function (skill, player, context)
    if not player:hasSkill(skill:objectName())
    or player:getPhase() ~= sgs.Player_Finish then
        return
    end
    local room = player:getRoom()
    local count = 0
    for _, p in sgs.qlist(room:getAlivePlayers()) do
        if p:getMark('&zhubi') > 0 then
            count = count + 1
        end
    end
    if count == 0 then
        return
    end
    player:drawCards(count)
end)

New 'Skill' ('发🐽', {
    type = '主动',
    desc = [[
每回合限一次，对攻击范围+1内所有没有“🐽”的角色依次造成一点伤害。
]],
    useOnce = true,
})
--每回合限一次，对攻击范围内所有没有“🐽”的角色依次造成一点伤害。
: event('主动-使用', function (card, source, targets)
    local room = source:getRoom()
    local players = room:getOtherPlayers(source)

    for _, player in sgs.qlist(players) do
        if  player:getMark('&zhubi') == 0
        and source:inMyAttackRange(player, -1) then
            room:damage(sgs.DamageStruct(card, source, player, 1))
        end
    end
end)
