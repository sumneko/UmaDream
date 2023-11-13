UD.createUma('虹ヶ咲I', {
    hp       = 6,
    title    = '🐷',
    designer = '最萌小汐',
    --skills   = {'画🐽', '拍🐽', '发🐽'},
})

UD.createSkill('画🐽', {
    type = '自动',
    desc = [[
你每造成1点伤害，对方获得1层“🐽”。
拥有“🐽”的玩家回合结束时流失1点体力，然后失去一层“🐽”。
拥有“🐽”的玩家对你造成的伤害-1，然后失去一层“🐽”。
]],
})
: event('伤害-结束', function (self, player, data)
    print('造成了伤害！')
end)
