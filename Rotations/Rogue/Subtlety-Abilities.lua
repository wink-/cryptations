local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 4 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

local Rotation  = LibStub("Rotation")
local Unit      = LibStub("Unit")
local Spell     = LibStub("Spell")
local Player    = LibStub("Player")

function RSShurikenStormV1()
  if Spell.CanCast(SB["Shuriken Storm"], nil, 3, 35)
  and #Units.GetUnitsInRadius(PlayerUnit, 10, "hostile") >= 2 then
    return Spell.Cast(SB["Shuriken Storm"])
  end
end

function RSGloomblade()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Gloomblade"], Target, 3, 35)
  and Player.IsFacing(Target) then
    return Spell.Cast(SB["Gloomblade"], Target)
  end
end

function RSBackstab()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Backstab"], Target, 3, 35)
  and Player.IsFacing(Target) then
    return Spell.Cast(SB["Backstab"], Target)
  end
end

function RSNightbladeV1()

end
