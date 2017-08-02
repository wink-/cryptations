local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 4 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end
