-- Same as for the Example.lua
-- But notice that you must check for the specID here,
-- since the spellbook is available for the whole class and not only a single spec
local _, _, ClassID = UnitClass("player")

if ClassID ~= 1 then return end
if FireHack == nil then return end

-- Spells you need are "registered" here
-- The spell name as String is the Key, and the ID is the value
-- Access the ID's like this:
-- local FireballID = SB["Fireball"]
SB = {
  ["Fireball"] = 133,
  ["Fireblast"] = 108853
}
