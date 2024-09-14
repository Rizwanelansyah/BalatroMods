local function is_highest(_hand)
  local hand = G.GAME.hands[_hand]
  local res = true
  local same_level = 0
  for key, value in pairs(G.GAME.hands) do
    if key ~= _hand then
      if value.level > hand.level then
        res = false
      elseif value.level == hand.level then
        same_level = same_level + 1
      end
    end
  end
  if same_level > 0 then
    return false
  end
  return res
end

local function is_lowest(_hand)
  local hand = G.GAME.hands[_hand]
  local res = true
  local same_level = 0
  for key, value in pairs(G.GAME.hands) do
    if key ~= _hand then
      if value.level < hand.level then
        res = false
      elseif value.level == hand.level then
        same_level = same_level + 1
      end
    end
  end
  if same_level > 0 then
    return false
  end
  return res
end

local j = {
  config = { extra = { hand = 1, discard = 1 } },
  atlas = "file:trash_hand.png",
  cost = 3,
  blueprint_compat = false,
}

j.loc_txt = {
  name = "Trash Hand",
  text = {
    "if played poker hand is the",
    "{C:attention}lowest level{} {C:red}+#1#{} discard,",
    "if discarded poker hand is the",
    "{C:attention}highest level{} {C:blue}+#2#{} hand",
  },
}

function j:loc_vars(_, card)
  return { vars = { card.ability.extra.discard, card.ability.extra.hand } }
end

function j:calculate(card, ctx)
  if ctx.before then
    local hand, _, _, _, _ = G.FUNCS.get_poker_hand_info(G.play.cards)
    if is_lowest(hand) then
      ease_discard(card.ability.extra.discard)
      return { message = "+" .. card.ability.extra.discard, colour = G.C.RED }
    end
  elseif ctx.discard and ctx.other_card == ctx.full_hand[#ctx.full_hand] then
    local hand, _, _, _, _ = G.FUNCS.get_poker_hand_info(ctx.full_hand)
    if is_highest(hand) then
      ease_hands_played(card.ability.extra.hand)
      return { message = "+" .. card.ability.extra.hand, colour = G.C.BLUE }
    end
  end
end

return j
