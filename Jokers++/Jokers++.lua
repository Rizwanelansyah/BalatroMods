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

local mod_path = SMODS.current_mod.path
package.path = package.path
    .. ";" .. mod_path .. "/module/?.lua"
    .. ";" .. mod_path .. "/module/?/init.lua"

_G.jpp_util = {}
function jpp_util.in_table(v, t)
  for _, value in ipairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

---TODO: Automate this later with listing directories
local jokers = {
  "statue",
  "miner",
  "midas_hand",
  "reverse",
  "calculator",
}

local function create_atlas(image, forced_key)
  local key = forced_key or image:match("^[^.]+")
  SMODS.Atlas {
    key = key,
    path = image,
    px = 71,
    py = 95,
  }
  return key
end

for _, mod in ipairs(jokers) do
  local options = require("jpp.jokers." .. mod) or {}
  local defaults = {
    key = mod,
    unlocked = true,
    discovered = true,
  }
  for key, value in pairs(defaults) do
    options[key] = options[key] or value
  end
  options.rarity = ({
    U = 2,
    R = 3,
    L = 3,
  })[options.rarity] or 1

  local default_loc = options.loc_txt
  local ok, loc = pcall(require, "jpp.jokers." .. mod .. ".loc")
  options.loc_txt = ok and loc or {}
  options.loc_txt.default = default_loc

  local atlas = options.atlas
  if type(atlas) == "string" then
    local name, image = string.match(options.atlas, "^file%(([%w%d_]+)%):(.+)$")
    image = image or string.match(options.atlas, "^file:(.+)$")
    options.atlas = image and create_atlas(image, name) or atlas
  elseif type(atlas) == "table" then
    local key
    if atlas[1] then
      for i, image in ipairs(atlas) do
        if image then
          create_atlas(image)
          if i == 1 then
            key = create_atlas(image)
          end
        end
      end
    else
      local first = true
      for name, image in pairs(atlas) do
        local main = string.match(name, "^main_([%w%d_]+)$")
        if main or first then
          key = create_atlas(image, main or name)
          first = false
        else
          create_atlas(image, name)
        end
      end
    end
    options.atlas = key
  end
  SMODS.Joker(options)
end

----------------------------------------------
------------MOD CODE END----------------------
