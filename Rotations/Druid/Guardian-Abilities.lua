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
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Moonfire"], PlayerTarget)
  and Moonfire
  and Unit.IsInLOS(PlayerTarget)
  and (Buff.Has(PlayerUnit, AB["Galactic Guardian"])
  or not Debuff.Has(PlayerTarget, AB["Moonfire"])) then
    return Spell.Cast(SB["Moonfire"], PlayerTarget)
  end
end

function DGMangle()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Mangle"], PlayerTarget) then
    return Spell.Cast(SB["Mangle"], PlayerTarget)
  end
end

function DGThrash()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Thrash Bear"], nil, nil, nil, false)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(SB["Thrash Bear"])
  end
end

function DGPulverize()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Pulverize"], PlayerTarget)
  and Debuff.Stacks(PlayerTarget, AB["Thrash Bear"]) >= 2 then
    return Spell.Cast(SB["Pulverize"], PlayerTarget)
  end
end

function DGMaul()
  local Rage = UnitPower("player", 1)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Maul"], PlayerTarget, 1, 45)
  and Rage >= MaulRage
  and Unit.PercentHealth(PlayerUnit) >= MaulHealth then
    return Spell.Cast(SB["Maul"], PlayerTarget)
  end
end

function DGSwipe()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Swipe Bear"])
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(SB["Swipe Bear"])
  end
end

function DGGrowl()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Growl"], PlayerTarget)
  and Unit.IsHostile(PlayerTarget)
  and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(SB["Growl"], PlayerTarget)
  end
end
