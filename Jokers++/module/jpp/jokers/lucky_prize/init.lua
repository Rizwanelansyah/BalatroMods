local function prize(name, desc, color, reward)
  local p = {
    name = name or "Empty",
    colour = color or G.C.GREEN,
  }
  p.desc = desc or p.name
  if type(reward) == "function" then
    p.get_reward = reward
  elseif type(reward) == "table" then
    p.get_reward = function()
      return reward
    end
  else
    p.get_reward = function()
      return {
        message = p.name .. "!",
        colour = p.colour,
      }
    end
  end
  return p
end

local empty = prize("Empty", "Do Nothing", G.C.RED)
local prizes = {
  empty,
  function()
    local money = math.floor(math.random() * 4) + 1
    local colour = G.C.MONEY
    return prize("Money " .. money, "Give $" .. money, colour, function()
      return { message = localize("$") .. money, colour = colour }
    end)
  end,
  function()
    local mult = math.floor(math.random() * 25) + 5
    local colour = G.C.MULT
    return prize("Mult " .. mult, "+" .. mult .. " mult", colour, function()
      return { mult = mult }
    end)
  end,
  function()
    local chips = math.floor(math.random() * 80) + 20
    local colour = G.C.CHIPS
    return prize("Chips " .. chips, "+" .. chips .. " chips", colour, function()
      return { chips = chips }
    end)
  end,
  function()
    local mult = math.floor(math.random() * 10) + 10
    local colour = G.C.XMULT
    return prize("Mult " .. (mult - 10), "x" .. mult .. " mult", colour, function()
      return { x_mult = mult * 0.1 }
    end)
  end,
  prize("More Hand", "+1 hand", G.C.BLUE, function()
    ease_hands_played(1)
    return { message = "+1 Hand!", colour = G.C.BLUE }
  end),
  prize("Trash", "+1 discard", G.C.BLUE, function()
    ease_discard(1)
    return { message = "+1 Discard!", colour = G.C.BLUE }
  end),
}

local function random_prizes()
  local new_prizes = {}
  for i = 1, 4 do
    local index = math.floor(math.random() * (#prizes - 1)) + 1
    local rand_prize = prizes[index]
    new_prizes[i] = (type(rand_prize) == "function" and rand_prize() or rand_prize)
  end
  return new_prizes
end

---FIXME: Find out why after this joker redraw always get an ERROR!
local j = {
  atlas = {
    LuckyPrizeT = "lucky_prize_t.png",
    LuckyPrizeTL = "lucky_prize_tl.png",
    LuckyPrizeTR = "lucky_prize_tr.png",
    LuckyPrizeBL = "lucky_prize_bl.png",
    LuckyPrizeBR = "lucky_prize_br.png",
    LuckyPrizeB = "lucky_prize_b.png",
    LuckyPrizeL = "lucky_prize_l.png",
    LuckyPrizeR = "lucky_prize_r.png",
  },
  config = {
    extra = { prizes = { empty, empty, empty, empty } }
  },
  rarity = "U",
  cost = 7,
}

j.loc_txt = {
  name = "Lucky Prize",
  text = {
    "Get random {C:attention}prizes{}",
    "list of {C:attention}prizes{}:",
    "{C:purple}[1]{} {V:1}#1#{} = {C:important}#2#{}",
    "{C:blue}[2]{} {V:2}#3#{} = {C:important}#4#{}",
    "{C:red}[3]{} {V:3}#5#{} = {C:important}#6#{}",
    "{V:5}[4]{} {V:4}#7#{} = {C:important}#8#{}",
    "{C:inactive}(prizes change after {}{C:blue}hand{}{C:inactive} played){}"
  },
}

function j:loc_vars(_, card)
  local vars = { colours = {} }
  for _, p in ipairs(card.ability.extra.prizes) do
    table.insert(vars, p.name)
    table.insert(vars, p.desc)
    table.insert(vars.colours, p.colour)
  end
  table.insert(vars.colours, G.C.ORANGE)
  return { vars = vars }
end

function j:calculate(card, ctx)
  if ctx.after and not ctx.blueprint then
    card.ability.extra.prizes = random_prizes()
    return {
      message = "Redraw!",
      colour = G.C.GREEN,
    }
  elseif ctx.joker_main then
    ---TODO: Get random prize and animate the sprite
  end
end

function j:set_ability(card)
  card.ability.extra.prizes = random_prizes()
end

return j
