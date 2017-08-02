local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if FireHack == nil then return end

local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

function PRebuke(Target)
  if Target == nil then
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Rebuke"], Target)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Rebuke"], Target)
  end
end

function PBlindingLight()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Blinding Light"])
  and Unit.IsInLOS(Target)
  and Unit.IsInRange(PlayerUnit, Target, 10) then
    return Spell.Cast(SB["Blinding Light"], Target)
  end
end

function PHammerOfJustice(Target)
  if Target == nil then
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Hammer of Justice"], Target)
  and Unit.IsInLOS(Target)
  and not Unit.IsBoss(Target) then
    return Spell.Cast(SB["Hammer of Justice"], Target)
  end
end
