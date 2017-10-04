local PaladinCommon = LibStub("PaladinCommon")
local Spell         = LibStub("Spell")
local Unit          = LibStub("Unit")

function PaladinCommon.Rebuke(Target)
  if Target == nil then
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Rebuke"], Target)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Rebuke"], Target)
  end
end

function PaladinCommon.BlindingLight()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Blinding Light"])
  and Unit.IsInLOS(Target)
  and Unit.IsInRange(PlayerUnit, Target, 10) then
    return Spell.Cast(SB["Blinding Light"], Target)
  end
end

function PaladinCommon.HammerOfJustice(Target)
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
