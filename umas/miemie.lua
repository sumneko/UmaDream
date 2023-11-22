local uma = New 'Uma' ('是咩咩不是喵喵、', {
    hp       = 6,
    title    = '🐏',
    designer = '最萌小汐',
    skills   = {'爆照', '圆角', '胆小'}
})

--检查一张牌的花色、点数、名字是否可以在“群精华”中找到
---@param card sgs.Card
---@param player sgs.ServerPlayer
local function checkCard(card, player)
    local myName = card:getName()
    local mySuit = card:getSuit()
    local myNumber = card:getNumber()
    local cardIDs = player:getPile("qunjinhua")
    print('check card', myName, mySuit, myNumber, cardIDs:length())
    local foundName, foundSuit, foundNumber
    ---@param destID integer
    for _, destID in sgs.qlist(cardIDs) do
        local dest = sgs.Sanguosha:getCard(destID)
        if myName == dest:getName() then
            foundName = true
        end
        if mySuit == dest:getSuit() then
            foundSuit = true
        end
        if myNumber == dest:getNumber() then
            foundNumber = true
        end
    end
    return foundName and foundSuit and foundNumber
end

sgs.LoadTranslationTable {
    ['qunjinhua'] = '群精华',
}

New 'Skill' ('爆照', {
    type = '被动',
    desc = [[
将你获得的牌置入“群精华”区，除非它的花色、点数、名字均可以在“群精华”中找到。
]]
})
: event('卡牌-移动', function (skill, player, context, moveInfo)
    if not moveInfo.to
    or moveInfo.to:objectName() ~= player:objectName()
    or not moveInfo.to:hasSkill(skill:objectName())
    or moveInfo.from == moveInfo.to
    or moveInfo.to_place ~= sgs.Player_PlaceHand then
        return
    end
    for _, cardID in sgs.qlist(moveInfo.card_ids) do
        local card = sgs.Sanguosha:getCard(cardID)
        if not checkCard(card, player) then
            log.info('爆照 addToPile', card:objectName())
            player:addToPile('qunjinhua', card, true)
        end
    end
end)

return uma
