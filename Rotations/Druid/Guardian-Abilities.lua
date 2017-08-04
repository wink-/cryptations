local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function SwitchToBearForm()
  if AutoSwitchForm
  and not Player.IsInShapeshift() then
    return Spell.Cast(SB["Bear Form"])
  end
end

function DGSurvivalInstincts()
  if Spell.CanCast(SB["Survival Instincts"])
  and SurvInstincts
  and (Unit.PercentHealth(PlayerUnit) <= SIHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Survival Instincts"])
  end
end

function DGBarkskin()
  if Spell.CanCast(SB["Barkskin"])
  and Barkskin
  and (Unit.PercentHealth(PlayerUnit) <= BSHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Barkskin"])
  end
end

function DGRotS()
  if Spell.CanCast(SB["Rage of the Sleeper"])
  and RotS
  and (Unit.PercentHealth(PlayerUnit) <= RotSHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Rage of the Sleeper"])
  end
end

function DGIronfur()
  if Spell.CanCast(SB["Ironfur"])
  and Ironfur
  and (Unit.PercentHealth(PlayerUnit) <= IFHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Ironfur"])
  end
end

function DGFrenziedRegeneration()
  if Spell.CanCast(SB["Frenzied Regeneration"])
  and FRegen
  and Player.GetDamageOverPeriod(5) >= UnitHealthMax(PlayerUnit) * (FRHealth / 100) then
    return Spell.Cast(SB["Frenzied Regeneration"])
  end
end

function DGMoonfire()
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

function DGMangle()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Mangle"], Target) then
    return Spell.Cast(SB["Mangle"], Target)
  end
end

function DGThrash()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Thrash Bear"], nil, nil, nil, false)
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Thrash Bear"])
  end
end

function DGPulverize()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Pulverize"], Target)
  and Debuff.Stacks(Target, AB["Thrash Bear"]) >= 2 then
    return Spell.Cast(SB["Pulverize"], Target)
  end
end

function DGMaul()
  local Target = PlayerTarget()

  local Rage = UnitPower("player", 1)
  if Target ~= nil
  and Spell.CanCast(SB["Maul"], Target, 1, 45)
  and Rage >= MaulRage
  and Unit.PercentHealth(PlayerUnit) >= MaulHealth then
    return Spell.Cast(SB["Maul"], Target)
  end
end

function DGSwipe()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Swipe Bear"])
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Swipe Bear"])
  end
end

function DGLunarBeam()
  if Spell.CanCast(SB["Lunar Beam"]) then
    return Spell.Cast(SB["Lunar Beam"])
  end
end

function DGIncarnation()
  if Incarnation
  and Spell.CanCast(SB["Incarnation: Guardian of Ursoc"]) then
    return Spell.Cast(SB["Incarnation: Guardian of Ursoc"])
  end
end

function DGBristlingFur()
  if BristlinFur
  and Spell.CanCast(SB["Bristling Fur"])
  and BossManager.IsDefCooldownNeeded()
  and not Buff.Has(PlayerUnit, AB["Survival Instincts"])
  and not Buff.Has(PlayerUnit, AB["Barkskin"]) then
    return Spell.Cast(SB["Bristling Fur"])
  end
end
