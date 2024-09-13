local j = {
  atlas = "file:reverse.png",
  cost = 4,
}

j.loc_txt = {
  name = "Reverse",
  text = {
    "Swap {C:mult}mult{} and {C:chips}chips{}",
  },
}

function j:calculate(card, ctx)
  if ctx.joker_main then
    local mod = hand_chips - mult
    return {
      mult_mod = mod,
      chip_mod = -mod,
      message = "Reverse!",
      colour = math.random() > 0.5 and G.C.CHIPS or G.C.MULT,
    }
  end
end

return j
