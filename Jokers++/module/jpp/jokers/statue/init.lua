local j = {
  atlas = "file:statue_of_joker.png",
  config = { extra = { mult = 0, scaling = 1, } },
  cost = 4,
}

j.loc_txt = {
  name = "Statue Of Joker",
  text = {
    "Gain {C:mult}+#1#{} mult",
    "for all {C:attention}not scored{} card",
    "{C:inactive}(Currently {}{C:mult}+#2#{} {C:inactive}mult){}"
  },
}

function j:calculate(card, ctx)
  if ctx.joker_main then
    return {
      mult_mod = card.ability.extra.mult,
      message = localize { type = "variable", key = "a_mult", vars = { card.ability.extra.mult } },
    }
  elseif ctx.before and not ctx.blueprint_card then
    local _, _, _, scoring_hand, _ = G.FUNCS.get_poker_hand_info(G.play.cards)
    local unscored_card = #G.play.cards - #scoring_hand
    if unscored_card > 0 then
      card.ability.extra.mult = card.ability.extra.mult + (unscored_card * card.ability.extra.scaling)

      return {
        message = localize('k_val_up'),
        colour = G.C.MULT,
      }
    end
  end
end

function j:loc_vars(_, card)
  return { vars = { card.ability.extra.scaling, card.ability.extra.mult } }
end

return j
