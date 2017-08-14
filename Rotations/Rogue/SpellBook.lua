local _, _, ClassID = UnitClass("player")

if ClassID ~= 4 then return end
if FireHack == nil then return end

SB = {
  ["Alacrity"] = 193539,
  ["Backstab"] = 53,
  ["Bloodlust"] = 2825,
  ["Dark Shadow"] = 245687,
  ["Death from Above"] = 152150,
  ["Deepening Shadows"] = 185314,
  ["Deeper Stratagem"] = 193531,
  ["Eviscerate"] = 196819,
  ["Gloomblade = "] = 200758,
  ["Goremaw's Bite"] = 209783,
  ["Kidney Shot"] = 408,
  ["Marked for Death"] = 137619,
  ["Master of Shadows"] = 196976,
  ["Master of Subtlety"] = 31223,
  ["Nightblade"] = 195452,
  ["Relentless Strikes"] = 58423,
  ["Shadow Blades"] = 121471,
  ["Shadow Dance"] = 185313,
  ["Shadow Techniques"] = 196912,
  ["Shadowstrike"] = 185438,
  ["Shuriken Storm"] = 197835,
  ["Shuriken Toss"] = 114014,
  ["Sprint"] = 2983,
  ["Stealth"] = 1784,
  ["Symbols of Death"] = 212283,
  ["Vanish"] = 1856,
}
