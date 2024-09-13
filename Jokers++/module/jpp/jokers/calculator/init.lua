local function get_random_op()
  local v = math.random()
  if v > 0.6 then
    return "Add"
  elseif v > 0.3 then
    return "Subtract"
  elseif v > 0.1 then
    return "Multi"
  else
    return "Divide"
  end
end

local function calcjoker_redraw(card)
  card.config.center.atlas = "jpp_CalculatorJoker" .. card.ability.extra.operator
  card:set_sprites(card.config.center)
end

local function do_operator(name, x, y)
  if name == "Add" then
    return x + y
  elseif name == "Subtract" then
    return x - y
  elseif name == "Multi" then
    return x * y
  elseif name == "Divide" then
    return x / y
  end
  return x
end

local symbols = {
  Add = "+",
  Subtract = "-",
  Multi = "x",
  Divide = "/",
}

local j = {
  key = "calculator",
  atlas = {
    main_CalculatorJokerAdd = "calculator_add.png",
    CalculatorJokerSubract = "calculator_subtract.png",
    CalculatorJokerMulti = "calculator_multi.png",
    CalculatorJokerDivide = "calculator_divide.png",
  },
  config = { extra = { operator = "Add" } },
  rarity = 'R',
  cost = 9,
}

j.loc_txt = {
  name = "Calculator",
  text = {
    "Calculate all played {C:attention}Number Card{}",
    "with {C:attention}#1#{} operator",
    "number start with current {C:mult}mult{}",
    "the result will not be {C:attention}less than{}",
    "base {C:mult}mult{} of played {C:attention}poker hand{}",
    "and set {C:mult}mult{} to the result,",
    "{C:inactive}operator can change after {}{C:blue}hand{}{C:inactive} played{}",
    "{C:inactive}or when {}{C:red}discard{}{C:inactive} playing card{}",
    "{C:inactive}({}e.g {C:mult}20{} + 4 {C:spades}Spades{} + 4 {C:hearts}Hearts{} + 2 {C:clubs}Spades{} + 2 {C:clubs}Clubs{}{C:inactive}){}",
  },
}

function j:loc_vars(info_queue, card)
  return { vars = { card.ability.extra.operator } }
end

function j:set_ability(card, initial, delay_sprites)
  card.ability.extra.operator = get_random_op()
end

function j:update(card, dt)
  local new_atlas = "jpp_CalculatorJoker" .. card.ability.extra.operator
  local old_atlas = card.config.center.atlas
  if new_atlas ~= old_atlas then
    calcjoker_redraw(card)
  end
end

function j:calculate(card, ctx)
  if (ctx.after or (ctx.discard and ctx.other_card == ctx.full_hand[#ctx.full_hand])) and not ctx.blueprint then
    G.E_MANAGER:add_event(Event {
      func = function()
        local old_op = card.ability.extra.operator
        local new_op = get_random_op()
        if old_op ~= new_op then
          card_eval_status_text(card, 'extra', nil, nil, nil,
            { message = "Change!" })
          G.E_MANAGER:add_event(Event {
            func = function()
              card.ability.extra.operator = new_op
              calcjoker_redraw(card)
              return true
            end
          })
        end
        return true
      end
    })
  elseif ctx.joker_main then
    local text, _, _, scoring_hand, _ = G.FUNCS.get_poker_hand_info(G.play.cards)
    local result = mult
    local min = G.GAME.hands[text].mult
    for _, playing_card in ipairs(G.play.cards) do
      local id = playing_card:get_id()
      if id >= 2 and id <= 10 and not playing_card.debuff and jpp_util.in_table(playing_card, scoring_hand) then
        result = do_operator(card.ability.extra.operator, result, id)
        card_eval_status_text(playing_card, 'extra', nil, nil, nil,
          { message = string.format("Calc: %s%d", symbols[card.ability.extra.operator], id), colour = G.C.MULT })
      end
    end
    if result < min then
      result = min
    end
    return { mult_mod = result - mult, message = string.format("mult = %d", result), colour = G.C.MULT }
  end
end

return j
