local PaladinRetribution = LibStub("PaladinRetribution")
local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")

function PaladinRetribution.AvengingWrathJudgment()
  local Target = PlayerTarget()

  if Spell.CanCast(SB["Avenging Wrath"])
  and AvengingWrath
  and Debuff.Has(Target, AB["Judgment Retribution"])
  and Unit.IsInAttackRange(SB["Tempar's Verdict"], Target) then
    return Spell.Cast(SB["Avenging Wrath"])
  end
end

function PaladinRetribution.ShieldOfVengeance()
  if Spell.CanCast(SB["Shield of Vengeance"])
  and SoV
  and Unit.PercentHealth(PlayerUnit) ~= 100 then
    return Spell.Cast(SB["Shield of Vengeance"])
  end
end

function PaladinRetribution.Crusade()
  local HolyPower = UnitPower("player", 9)

  if Crusade
  and Spell.CanCast(SB["Crusade"])
  and HolyPower == 5 then
    return Spell.Cast(SB["Crusade"])
  end
end

function PaladinRetribution.HolyWrath()
  if HolyWrath
  and Spell.CanCast(SB["Holy Wrath"])
  and Unit.PercentHealth(PlayerUnit) <= HWHealth
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= HWUnits then
    return Spell.Cast(SB["Holy Wrath"])
  end
end

function PaladinRetribution.Consecration()
  if Spell.CanCast(SB["Consecration Retribution"])
  and not Unit.IsMoving(PlayerUnit)
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= 2 then
    return Spell.Cast(SB["Consecration Retribution"])
  end
end

function PaladinRetribution.WakeOfAshes()
  local Target    = PlayerTarget()
  local HolyPower = UnitPower("player", 9)

  if HolyPower <= 1
  and Player.ArtifactTraitRank(179546) ~= 0
  and Spell.CanCast(SB["Wake of Ashes"])
  and Player.IsFacing(Target) then
    return Spell.Cast(SB["Wake of Ashes"])
  end
end

-- TODO: add Righteous Verdict support if useful
function PaladinRetribution.BladeOfJustice()
  local Target = PlayerTarget()

  if Target ~= nil
  and not Player.HasTalent(4, 3)
  and Spell.CanCast(SB["Blade of Justice"], Target) then
    Spell.Cast(SB["Blade of Justice"], Target)
  end
end

-- TODO: add Righteous Verdict support if useful
function PaladinRetribution.DivineHammer()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(4, 3)
  and Spell.CanCast(SB["Divine Hammer"], Target) then
    Spell.Cast(SB["Divine Hammer"], Target)
  end
end

function PaladinRetribution.Zeal()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(2, 2)
  and Spell.CanCast(SB["Zeal"], Target) then
    Spell.Cast(SB["Zeal"], Target)
  end
end

function PaladinRetribution.CrusaderStrike()
  local Target = PlayerTarget()

  if Target ~= nil
  and not Player.HasTalent(2, 2)
  and Spell.CanCast(SB["Crusader Strike"], Target) then
    Spell.Cast(SB["Crusader Strike"], Target)
  end
end

function PaladinRetribution.JusticarsVengeance()
  local HolyPower = UnitPower("player", 9)

  if HolyPower == 5
  and Unit.PercentHealth(PlayerUnit) <= JVHealth
  and Spell.CanCast(SB["Justicar's Vengeance"]) then
    return Spell.Cast(SB["Justicar's Vengeance"])
  end
end

function PaladinRetribution.EyeForAnEye()
  if EfaE
  and Unit.PercentHealth(PlayerUnit) <= EfaEHealth
  and Spell.CanCast(SB["Eye for an Eye"]) then
    Spell.Cast(SB["Eye for an Eye"])
  end
end

function PaladinRetribution.WordOfGlory()
  if WoG
  and #Unit.GetUnitsBelowHealth(WoGHealth, "friendly", true, PlayerUnit, 15) >= WoGUnits
  and Spell.CanCast(SB["Word of Glory"]) then
    Spell.Cast(SB["Word of Glory"])
  end
end

function PaladinRetribution.Judgment_Debuff()
  local Target    = PlayerTarget()
  local HolyPower = UnitPower("player", 9)

  if Target ~= nil
  and Spell.CanCast(SB["Judgment"], Target)
  and Unit.IsInAttackRange(SB["Templar's Verdict"], Target)
  and Unit.IsInLOS(Target)
  -- TODO: and TTD_TABLE[Target] >= JudgmentTTD
  and (HolyPower >= 3
  or (HolyPower >= 2
  and Player.HasTalent(2, 1))) then
    return Spell.Cast(SB["Judgment"], Target)
  end
end

function PaladinRetribution.ExecutionSentence()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(1, 2)
  and Spell.CanCast(SB["Execution Sentence"], Target, 9, 3) then
      return Spell.Cast(SB["Execution Sentence"], Target)
  end
end

function PaladinRetribution.DivineStorm_AOE()
  local Target = PlayerTarget()

  if Target~= nil
  and Spell.CanCast(SB["Divine Storm"], nil, 9, 3)
  and  Debuff.Has(Target, AB["Judgment Retribution"]) then
    return Spell.Cast(SB["Divine Storm"])
  end
end

function PaladinRetribution.DivineStorm_ST()
  local Target = PlayerTarget()

  if Target~= nil
  and Spell.CanCast(SB["Divine Storm"], nil, 9, 3)
  and Buff.Stacks(Target, AB["Scarlet Inquisitor's Expurgation"]) >= 25 then
    return Spell.Cast(SB["Divine Storm"])
  end
end

function PaladinRetribution.TemplarsVerdict()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Templar's Verdict"], Target, 9, 3)
  and Debuff.Has(Target, AB["Judgment Retribution"], true) then
    return Spell.Cast(SB["Templar's Verdict"], Target)
  end
end
