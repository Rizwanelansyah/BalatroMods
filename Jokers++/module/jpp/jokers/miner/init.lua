local j = {
  atlas = "file:miner_joker.png",
  config = { extra = { chips = 0, odds = 4, money_gain = 3, total_money_gain = 0 } },
  rarity = 'R',
  cost = 10,
}

j.loc_txt = {
  name = "Minner",
  text = {
    "Gain {C:chips}chips{} ({C:attention}extra chips included{})",
    "from all played {C:attention}Stone Card{},",
    "destroy {C:attention}Stone Card{} after scoring",
    "and {C:green}#2# in #3#{} chance to gain {C:money}$#4#{}",
    "for each {C:attention}Stone Card{} at",
    "the end of round",
    "{C:inactive}(Currently{} {C:chips}+#1#{} {C:inactive}chips){}"
  }
}

function j:loc_vars(_, card)
  return { vars = { card.ability.extra.chips, G.GAME.probabilities.normal or 1, card.ability.extra.odds, card.ability.extra.money_gain } }
end

function j:calculate(card, ctx)
  if ctx.individual and ctx.cardarea == G.play and ctx.other_card.ability.effect == "Stone Card" and not ctx.blueprint_card then
    local chips = ctx.other_card.ability.bonus + (ctx.other_card.ability.perma_bonus or 0)
    card.ability.extra.chips = card.ability.extra.chips + chips
    if pseudorandom("miner") < G.GAME.probabilities.normal / card.ability.extra.odds then
      card.ability.extra.total_money_gain = (card.ability.extra.total_money_gain or 0) + card.ability.extra.money_gain
    end
    return {
      extra = { message = localize('k_val_up'), colour = G.C.CHIPS },
      colour = G.C.CHIPS,
      card = card,
    }
  elseif ctx.destroying_card and not ctx.blueprint_card then
    return ctx.destroying_card.ability.effect == "Stone Card"
  elseif ctx.joker_main then
    return {
      chip_mod = card.ability.extra.chips,
      message = localize { type = "variable", key = "a_chips", vars = { card.ability.extra.chips } },
      colour = G.C.CHIPS,
    }
  end
end

function j:calc_dollar_bonus(card)
  local money = card.ability.extra.total_money_gain
  card.ability.extra.total_money_gain = 0
  if money > 0 then
    return money
  end
end

return j
