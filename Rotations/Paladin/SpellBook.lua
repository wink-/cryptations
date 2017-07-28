local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if FireHack == nil then return end

SB = {
  ["Rebuke"] = 96231,
  ["Blinding Light"] = 115750,
  ["Hammer of Justice"] = 853
}
