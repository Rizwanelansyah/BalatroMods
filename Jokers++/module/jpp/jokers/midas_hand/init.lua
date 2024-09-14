local j = {
  atlas = "file:midas_hand.png",
  config = { extra = { gold_seal_odds = 5, hand = 1 } },
  rarity = 'U',
  cost = 6,
}

j.loc_txt = {
  name = "Midas Hand",
  text = {
    "{C:blue}+#3#{} hand,",
    "card played on {C:attention}first hand{}",
    "turn into {C:attention}Gold Card{} and",
    "{C:green}#1# in #2#{} chance to add {C:attention}Gold Seal{}",
  },
}

function j:loc_vars(info_queue, card)
  table.insert(info_queue, G.P_CENTERS.m_gold)
  return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.gold_seal_odds, card.ability.extra.hand } }
end

function j:calculate(card, ctx)
  if ctx.before and G.GAME.current_round.hands_played == 0 then
    local _, _, _, scoring_hand, _ = G.FUNCS.get_poker_hand_info(G.play.cards)
    for _, playing_card in ipairs(G.play.cards) do
      if jpp_util.in_table(playing_card, scoring_hand) or playing_card.ability.effect == "Stone Card" then
        local gold_seal = pseudorandom("midas") < G.GAME.probabilities.normal / card.ability.extra.gold_seal_odds

        card_eval_status_text(playing_card, 'extra', nil, nil, nil,
          { message = localize("k_gold"), colour = G.C.MONEY })
        G.E_MANAGER:add_event(Event {
          func = function()
            playing_card:set_ability(G.P_CENTERS.m_gold)
            if gold_seal then
              playing_card:set_seal("Gold")
            end
            playing_card:juice_up()
            delay(0.2)
            return true
          end
        })
        delay(0.3)
      end
    end
  elseif ctx.setting_blind and not (ctx.blueprint_card or card).getting_sliced then
    ease_hands_played(card.ability.extra.hand)
    card_eval_status_text(ctx.blueprint_card or card, 'extra', nil, nil, nil,
      { message = localize { type = 'variable', key = 'a_hands', vars = { card.ability.extra.hand } } })
  end
end

return j
