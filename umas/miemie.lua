local uma = New 'Uma' ('是咩咩不是喵喵、', {
    id       = 'uma_miemie',
    hp       = 6,
    title    = '🐏',
    designer = '最萌小汐',
    skills   = {'爆照', '圆角', '胆小'}
})

--检查一张牌的花色、点数、名字是否可以在“群精华”中找到
---@param card sgs.Card
---@param player sgs.ServerPlayer
local function checkCard(card, player)
    local mySuit = card:getSuit()
    local myNumber = card:getNumber()
    local myType = card:getType()
    local cardIDs = player:getPile("qunjinhua")
    local foundType, foundSuit, foundNumber
    ---@param destID integer
    for _, destID in sgs.qlist(cardIDs) do
        local dest = sgs.Sanguosha:getCard(destID)
        if myType == dest:getType() then
            foundType = true
        end
        if mySuit == dest:getSuit() then
            foundSuit = true
        end
        if myNumber == dest:getNumber() then
            foundNumber = true
        end
    end
    return foundType and foundSuit and foundNumber
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
    or moveInfo.from == moveInfo.to
    or moveInfo.to_place ~= sgs.Player_PlaceHand
    or UD.util.arrayHas(moveInfo.from_pile_names, 'qunjinhua') then
        return
    end
    local room = player:getRoom()
    for _, cardID in sgs.qlist(moveInfo.card_ids) do
        local card = sgs.Sanguosha:getCard(cardID)
        if  room:getCardPlace(cardID) == sgs.Player_PlaceHand
        and room:getCardOwner(cardID) == player
        and not checkCard(card, player) then
            player:addToPile('qunjinhua', card, true)
        end
    end
end)

New 'Skill' ('圆角', {
    type = '被动',
    desc = [[
回合外每当一张牌从你之外的地方进入弃牌堆时，若它的花色、点数、名字均可以在“群精华”中找到，则将其置入你的手牌（不触发【爆照】）。
]]
})
: event('卡牌-移动', function (skill, player, context, moveInfo)
    if moveInfo.to_place ~= sgs.Player_DiscardPile
    or player:getPhase() ~= sgs.Player_NotActive
    or (moveInfo.from and moveInfo.from:objectName() == player:objectName()) then
        return
    end
    local room = player:getRoom()
    for _, cardID in sgs.qlist(moveInfo.card_ids) do
        local card = sgs.Sanguosha:getCard(cardID)
        if  room:getCardPlace(cardID) == sgs.Player_DiscardPile
        and checkCard(card, player) then
            room:moveCardTo(card, player, sgs.Player_PlaceHand, true)
        end
    end
end)

New 'Skill' ('胆小', {
    type = '主动',
    cost = 999,
    costMin = 1,
    useOnce = true,
    desc = [[
每回合限一次，将任意张手牌与“群精华”中的牌交换（不触发【爆照】）。
]]
})
: event('主动-选牌', function (source, selected, toSelect)
    return #selected < source:getPile("qunjinhua"):length()
end)
: event('主动-使用', function (card, source, targets)
    local subCards = card:getSubcards()
    local count = subCards:length()
    local room = source:getRoom()
    local cardIDs = source:getPile("qunjinhua")
    room:fillAG(cardIDs, source)
    for _ = 1, count do
        local cardID = room:askForAG(source, cardIDs, false, card:objectName())
        room:takeAG(source, cardID, false)
        room:moveCardTo(sgs.Sanguosha:getCard(cardID), source, sgs.Player_PlaceHand, true)
    end
    room:clearAG(source)
    for _, cardID in sgs.qlist(subCards) do
        local card = sgs.Sanguosha:getCard(cardID)
        source:addToPile('qunjinhua', card, true)
    end
end)

return uma
