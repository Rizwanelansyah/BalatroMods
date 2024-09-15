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

function jpp_util.ls(path)
  local t = {}
  for dir in io.popen(string.format([[dir "%s" /b]], path)):lines() do
    table.insert(t, dir)
  end
  return t
end

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

local jokers = {}
local jokers_path = mod_path .. "\\module\\jpp\\jokers"
local files = jpp_util.ls(jokers_path)
for _, name in ipairs(files) do
  table.insert(jokers, name)
end

for _, mod in ipairs(jokers) do
  local options = require("jpp.jokers." .. mod)
  if not options then
    goto continue
  end
  local defaults = {
    key = mod,
    unlocked = true,
    discovered = true,
  }
  for key, value in pairs(defaults) do
    options[key] = options[key] or value
  end
  options.rarity = type(options.rarity) == "number" and options.rarity or (({
    U = 2,
    R = 3,
    L = 3,
  })[options.rarity] or 1)

  local default_loc = options.loc_txt
  local ok, loc = pcall(require, "jpp.jokers." .. mod .. ".loc")
  options.loc_txt = ok and loc or {}
  options.loc_txt.default = default_loc

  if options.atlas then
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
          if first then
            if type(image) == "string" then
              key = create_atlas(image, name)
            else
              image.key = name
              image.px = image.px or 71
              image.py = image.py or 95
              SMODS.Atlas(image)
              key = name
            end
            first = false
          else
            if type(image) == "string" then
              create_atlas(image, name)
            else
              image.key = name
              image.px = image.px or 71
              image.py = image.py or 95
              SMODS.Atlas(image)
            end
          end
        end
      end
      options.atlas = key
    end
  end
  local j = SMODS.Joker(options)
  if mod == "combo_wombo" then
    for key, value in pairs(j) do
      sendInfoMessage(string.format("%s = %s", key, tostring(value)), "J++")
    end
  end
  ::continue::
end

----------------------------------------------
------------MOD CODE END----------------------
