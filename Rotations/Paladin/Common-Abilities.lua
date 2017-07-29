local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if FireHack == nil then return end

local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

function PRebuke()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Rebuke"], PlayerTarget)
  and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(SB["Rebuke"], PlayerTarget)
  end
end

function PBlindingLight()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Blinding Light"])
  and Unit.IsInLOS(PlayerTarget)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 10) then
    return Spell.Cast(SB["Blinding Light"], PlayerTarget)
  end
end

function PHammerOfJustice()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Hammer of Justice"], PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and not Unit.IsBoss(PlayerTarget) then
    return Spell.Cast(SB["Hammer of Justice"], PlayerTarget)
  end
end
