--- STEAMODDED HEADER
--- MOD_NAME: Jokers++
--- MOD_ID: jokers_plus_plus
--- MOD_AUTHOR: [Rizwanelansyah]
--- MOD_DESCRIPTION: More Jokers
--- PREFIX: jpp

----------------------------------------------
------------MOD CODE -------------------------
---@diagnostic disable: undefined-global
---@diagnostic disable: unused-local

local util = {}
function util.in_table(v, t)
  for _, value in ipairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

local function Atlas(tbl)
  tbl.px = tbl.px or 71
  tbl.py = tbl.py or 95
  SMODS.Atlas(tbl)
end

local Rarity = {
  Common = 1,
  Uncommon = 2,
  Rare = 3,
  Legendary = 4,
}

Atlas {
  key = "StatueOfJoker",
  path = "statue_of_joker.png",
}
Atlas {
  key = "MinerJoker",
  path = "miner_joker.png",
}
Atlas {
  key = "MidasJoker",
  path = "midas_joker.png",
}
Atlas {
  key = "ReverseJoker",
  path = "reverse_joker.png",
}

SMODS.Joker {
  key = "statue",
  atlas = "StatueOfJoker",
  loc_txt = {
    name = "Statue of Joker",
    text = {
      "Gain {C:mult}+#1#{} mult for",
      "each {C:attention}unscored{} card ",
      "{C:inactive}(Currently {C:mult}+#2#{}{C:inactive} mult){}"
    },
  },
  config = { extra = { mult = 0, scaling = 1, } },
  rarity = Rarity.common,
  cost = 4,
  unlocked = true,
  discovered = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.scaling, card.ability.extra.mult } }
  end,
  calculate = function(self, card, ctx)
    if ctx.joker_main then
      return {
        mult_mod = card.ability.extra.mult,
        message = localize { type = "variable", key = "a_mult", vars = { card.ability.extra.mult } },
      }
    elseif ctx.before then
      local text, disp_text, poker_hands, scoring_hand, non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.play.cards)
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
}

SMODS.Joker {
  key = "minner",
  atlas = "MinerJoker",
  loc_txt = {
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
  },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chips, G.GAME.probabilities.normal or 1, card.ability.extra.odds, card.ability.extra.money_gain } }
  end,
  calculate = function(self, card, ctx)
    if ctx.individual and ctx.cardarea == G.play and ctx.other_card.ability.effect == "Stone Card" then
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
    elseif ctx.destroying_card then
      return ctx.destroying_card.ability.effect == "Stone Card"
    elseif ctx.joker_main then
      return {
        chip_mod = card.ability.extra.chips,
        message = localize { type = "variable", key = "a_chips", vars = { card.ability.extra.chips } },
        colour = G.C.CHIPS,
      }
    end
  end,
  calc_dollar_bonus = function(self, card)
    local money = card.ability.extra.total_money_gain
    card.ability.extra.total_money_gain = 0
    if money > 0 then
      return money
    end
  end,
  config = { extra = { chips = 0, odds = 4, money_gain = 3, total_money_gain = 0 } },
  rarity = Rarity.Rare,
  cost = 10,
  unlocked = true,
  discovered = true,
}

SMODS.Joker {
  key = "midas",
  atlas = "MidasJoker",
  loc_txt = {
    name = "Midas Hand",
    text = {
      "{C:blue}+#3#{} hand,",
      "card played on {C:attention}first hand{}",
      "turn into {C:attention}Gold Card{} and",
      "{C:green}#1# in #2#{} chance to add {C:attention}Gold Seal{}",
    },
  },
  config = { extra = { gold_seal_odds = 5, hand = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.gold_seal_odds, card.ability.extra.hand } }
  end,
  calculate = function(self, card, ctx)
    if ctx.before and G.GAME.current_round.hands_played == 0 then
      local text, disp_text, poker_hands, scoring_hand, non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.play.cards)
      for _, playing_card in ipairs(G.play.cards) do
        if util.in_table(playing_card, scoring_hand) or playing_card.ability.effect == "Stone Card" then
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
  end,
  rarity = Rarity.Uncommon,
  cost = 6,
  unlocked = true,
  discovered = true,
}

SMODS.Joker {
  key = "reverse",
  atlas = "ReverseJoker",
  loc_txt = {
    name = "Reverse",
    text = {
      "Swap {C:mult}mult{} and {C:chips}chips{}",
    },
  },
  calculate = function(self, card, ctx)
    if ctx.joker_main then
      local mod = hand_chips - mult
      return {
        mult_mod = mod,
        chip_mod = -mod,
        message = "Reverse!",
        colour = math.random() > 0.5 and G.C.CHIPS or G.C.MULT,
      }
    end
  end,
  rarity = Rarity.Common,
  cost = 4,
  unlocked = true,
  discovered = true,
}

----------------------------------------------
------------MOD CODE END----------------------
