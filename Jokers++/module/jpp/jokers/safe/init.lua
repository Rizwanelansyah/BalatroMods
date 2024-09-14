local mapping = {
  "", "2", "3", "4", "5",
  "6", "7", "8", "9", "10",
  "J", "Q", "K", "A",
}

local function passwd()
  local password = {}
  for i = 1, 3 do
    local key = math.floor(math.random() * 12) + 2
    password[i] = { id = key, revealed = false }
  end
  return password
end

local function reveal(password, len)
  local revealed = 0
  for i = 1, #password do
    if revealed < len then
      if not password[i].revealed then
        password[i].revealed = true
        revealed = revealed + 1
      end
    else
      return
    end
  end
end

local function stringify(password)
  local str = ""
  for i, p in ipairs(password) do
    if i ~= 1 then
      str =  str .. " "
    end
    str = str .. (p.revealed and mapping[p.id] or "?")
  end
  return str
end

local function match(password, cards)
  local correct = 0
  local correct_cards = {}
  for _, p in ipairs(password) do
    for _, card in ipairs(cards) do
      if card:get_id() == p.id then
        correct = correct + 1
        table.insert(correct_cards, card)
        break
      end
    end
  end
  return correct >= 3, correct_cards
end

local j = {
  atlas = "file:safe.png",
  cost = 3,
  config = { extra = { scaling = 1.2, money = 3, password = passwd(), unlocked = false } },
  blueprint_compat = false,
}

j.loc_txt = {
  name = "Safe",
  text = {
    "When {C:attention}played cards{} contains the {C:attention}password{}, give {C:money}$#1#{} then",
    "create new {C:attention}password{} and scale up the {C:money}money{},",
    "current {C:attention}password{}: {C:green}#2#{}",
    "{C:inactive}(Password will reveal each hand played){}",
  },
}

function j:loc_vars(_, card)
  return { vars = { card.ability.extra.money, stringify(card.ability.extra.password) } }
end

function j:set_ability(card)
  card.ability.extra.password = passwd()
  reveal(card.ability.extra.password, math.floor(math.random() * 2) + 1)
end

function j:calculate(card, ctx)
  if ctx.joker_main then
    local _, _, _, scoring_hand, _ = G.FUNCS.get_poker_hand_info(G.play.cards)
    local correct, correct_cards = match(card.ability.extra.password, scoring_hand)
    if correct then
      for _, playing_card in ipairs(correct_cards) do
        card_eval_status_text(playing_card, 'extra', nil, nil, nil,
          { message = "Correct!", colour = G.C.GREEN })
      end

      card.ability.extra.unlocked = true
      card_eval_status_text(card, 'extra', nil, nil, nil,
        { message = "Unlocked!", colour = G.C.RED })

      ease_dollars(card.ability.extra.money)
      return {
        message = localize("$") .. card.ability.extra.money,
        colour = G.C.MONEY
      }
    end
  elseif ctx.after and card.ability.extra.unlocked then
    card.ability.extra.unlocked = false
    local m = card.ability.extra.money
    card.ability.extra.money = m + math.floor(m * card.ability.extra.scaling)
    card.ability.extra.password = passwd()
    reveal(card.ability.extra.password, math.floor(math.random() * 1))

    return {
      message = "Locked!",
      colour = G.C.GREEN,
    }
  elseif ctx.after and not card.ability.extra.unlocked then
    reveal(card.ability.extra.password, math.floor(math.random() * 2))
  end
end

return j
