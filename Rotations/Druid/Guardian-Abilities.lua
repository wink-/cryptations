local DruidGuardian = LibStub("DruidGuardian")
local Unit          = LibStub("Unit")
local Spell         = LibStub("Spell")
local Rotation      = LibStub("Rotation")
local Player        = LibStub("Player")
local Buff          = LibStub("Buff")
local Debuff        = LibStub("Debuff")
local BossManager   = LibStub("BossManager")

function DruidGuardian.SwitchToBearForm()
  if AutoSwitchForm
  and not Player.IsInShapeshift() then
    return Spell.Cast(SB["Bear Form"])
  end
end

function DruidGuardian.SurvivalInstincts()
  if Spell.CanCast(SB["Survival Instincts"])
  and SurvInstincts
  and (Unit.PercentHealth(PlayerUnit) <= SIHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Survival Instincts"])
  end
end

function DruidGuardian.Barkskin()
  if Spell.CanCast(SB["Barkskin"])
  and Barkskin
  and not Buff.Has(PlayerUnit, AB["Survival Instincts"])
  and (Unit.PercentHealth(PlayerUnit) <= BSHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Barkskin"])
  end
end

function DruidGuardian.RotS()
  if Spell.CanCast(SB["Rage of the Sleeper"])
  and RotS
  and (Unit.PercentHealth(PlayerUnit) <= RotSHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Rage of the Sleeper"])
  end
end

function DruidGuardian.Ironfur()
  if Spell.CanCast(SB["Ironfur"])
  and Ironfur
  and not Buff.Has(PlayerUnit, AB["Survival Instincts"])
  and (Unit.PercentHealth(PlayerUnit) <= IFHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Ironfur"])
  end
end

function DruidGuardian.FrenziedRegeneration()
  if Spell.CanCast(SB["Frenzied Regeneration"])
  and FRegen
  and Player.GetDamageOverPeriod(5) >= UnitHealthMax(PlayerUnit) * (FRHealth / 100) then
    return Spell.Cast(SB["Frenzied Regeneration"])
  end
end

function DruidGuardian.Moonfire()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Moonfire"], Target)
  and Moonfire
  and Unit.IsInLOS(Target)
  and (Buff.Has(PlayerUnit, AB["Galactic Guardian"])
  or not Debuff.Has(Target, AB["Moonfire"])) then
    return Spell.Cast(SB["Moonfire"], Target)
  end
end

function DruidGuardian.Mangle()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Mangle"], Target) then
    return Spell.Cast(SB["Mangle"], Target)
  end
end

function DruidGuardian.Thrash()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Thrash Bear"], nil, nil, nil, false)
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Thrash Bear"])
  end
end

function DruidGuardian.Pulverize()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Pulverize"], Target)
  and Debuff.Stacks(Target, AB["Thrash Bear"]) >= 2 then
    return Spell.Cast(SB["Pulverize"], Target)
  end
end

function DruidGuardian.Maul()
  local Target = PlayerTarget()

  local Rage = UnitPower("player", 1)
  if Target ~= nil
  and Spell.CanCast(SB["Maul"], Target, 1, 45)
  and Rage >= MaulRage
  and Unit.PercentHealth(PlayerUnit) >= MaulHealth then
    return Spell.Cast(SB["Maul"], Target)
  end
end

function DruidGuardian.Swipe()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Swipe Bear"])
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Swipe Bear"])
  end
end

function DruidGuardian.LunarBeam()
  if Spell.CanCast(SB["Lunar Beam"]) then
    return Spell.Cast(SB["Lunar Beam"])
  end
end

function DruidGuardian.Incarnation()
  if Incarnation
  and Spell.CanCast(SB["Incarnation: Guardian of Ursoc"]) then
    return Spell.Cast(SB["Incarnation: Guardian of Ursoc"])
  end
end

function DruidGuardian.BristlingFur()
  if BristlinFur
  and Spell.CanCast(SB["Bristling Fur"])
  and BossManager.IsDefCooldownNeeded()
  and not Buff.Has(PlayerUnit, AB["Survival Instincts"])
  and not Buff.Has(PlayerUnit, AB["Barkskin"]) then
    return Spell.Cast(SB["Bristling Fur"])
  end
end
