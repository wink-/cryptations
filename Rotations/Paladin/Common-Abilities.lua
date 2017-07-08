local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if FireHack == nil then return end

local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

function PRebuke()
  if PlayerTarget ~= nil
  and Spell.CanCast(96231, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(96231, PlayerTarget)
  end
end

function PBlindingLight()
  if PlayerTarget ~= nil
  and Spell.CanCast(115750)
  and Unit.IsInLOS(PlayerTarget)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 10) then
    return Spell.Cast(115750, PlayerTarget)
  end
end

function PHammerOfJustice()
  if PlayerTarget ~= nil
  and Spell.CanCast(853, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and not Unit.IsBoss(PlayerTarget) then
    return Spell.Cast(853, PlayerTarget)
  end
end
