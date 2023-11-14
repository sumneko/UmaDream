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
