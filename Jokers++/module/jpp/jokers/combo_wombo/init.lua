local function update_sprite(card)
  local combo = card.ability.extra.combo
  if combo > 7 then
    card.config.center.pos.x = 3
  elseif combo > 4 then
    card.config.center.pos.x = 2
  elseif combo > 1 then
    card.config.center.pos.x = 1
  else
    card.config.center.pos.x = 0
  end
  card:set_sprites(card.config.center)
end

local j = {
  config = { extra = { base = 8, mult = 8, scaling = 2.4, combo = 0 } },
  rarity = "U",
  cost = 5,
  atlas = "file:combo_wombo.png",
  pos = { x = 0, y = 0 }
}

j.loc_txt = {
  name = "Combo Wombo",
  text = {
    "Start with {C:mult}+#1#{} mult,",
    "{C:mult}mult{} will {C:attention}x#3#{} after {C:blue}hand{} played,",
    "{C:mult}mult{} will back to {C:mult}#1#{} after {C:red}discard{}",
    "and {C:red}reset{} at the {C:attention}end of round{}",
    "{C:inactive}(Currently will give {}{C:mult}+#2#{}{C:inactive} mult){}",
  },
}

function j:loc_vars(_, card)
  return { vars = { card.ability.extra.base, card.ability.extra.mult, card.ability.extra.scaling } }
end

function j:calculate(card, ctx)
  if
      (
        (ctx.end_of_round and not ctx.repetition and not ctx.individual)
        or (ctx.discard and ctx.other_card == ctx.full_hand[#ctx.full_hand])
      )
      and not ctx.blueprint
      and card.ability.extra.combo > 0
  then
    card.ability.extra.mult = card.ability.extra.base
    card.ability.extra.combo = 0
    update_sprite(card)
    return { message = localize("k_reset"), colour = G.C.RED }
  elseif ctx.before and not ctx.blueprint then
    card.ability.extra.combo = card.ability.extra.combo + 1
    update_sprite(card)
    if card.ability.extra.combo > 1 then
      return {
        message = "Combo x" .. card.ability.extra.combo,
        colour = G.C.MULT,
      }
    end
  elseif ctx.joker_main then
    return {
      mult_mod = card.ability.extra.mult,
      message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.mult } }),
      colour = G.C.MULT,
      card = ctx.blueprint or card,
    }
  elseif ctx.after and not ctx.end_of_round and not ctx.blueprint then
    card.ability.extra.mult = card.ability.extra.mult * card.ability.extra.scaling
  end
end

return j
