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
: event('伤害-造成后', function (self, player, damage)
    if damage.from ~= player
    or not damage.to
    or damage.to == player then
        return
    end
    damage.to:gainMark('&zhubi', 1)
end)

sgs.LoadTranslationTable {
    ['zhubi'] = '🐽',
}
