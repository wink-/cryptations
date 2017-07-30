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
  and not Player.IsInShapeshift()
  then
    return Spell.Cast(SB["Bear Form"])
  end
end

function DGSurvivalInstincts()
  if Spell.CanCast(SB["Survival Instincts"])
  and SurvInstincts then
    if Unit.PercentHealth(PlayerUnit) <= SIHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(SB["Survival Instincts"])
    end
  end
end

function DGBarkskin()
  if Spell.CanCast(SB["Barkskin"])
  and Barkskin then
    if Unit.PercentHealth(PlayerUnit) <= BSHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(SB["Barkskin"])
    end
  end
end

function DGRotS()
  if Spell.CanCast(SB["Rage of the Sleeper"]) and UseRotS then
    if Unit.PercentHealth(PlayerUnit) <= RotSHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(SB["Rage of the Sleeper"])
    end
  end
end

function DGIronfur()
  if Spell.CanCast(SB["Ironfur"]) and Ironfur then
    if Unit.PercentHealth(PlayerUnit) <= IFHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(SB["Ironfur"])
    end
  end
end

function DGFrenziedRegeneration()
  if Spell.CanCast(SB["Frenzied Regeneration"]) and FRegen then
    if Player.GetDamageOverPeriod(5) >= UnitHealthMax(PlayerUnit) * (FRHealth / 100) then
      return Spell.Cast(SB["Frenzied Regeneration"])
    end
  end
end

function DGMoonfire()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Moonfire"], PlayerTarget)
  and Moonfire
  and Unit.IsInLOS(PlayerTarget) then
    if Buff.Has(PlayerUnit, AB["Galactic Guardian"])
    or not Debuff.Has(PlayerTarget, AB["Moonfire"]) then
      return Spell.Cast(SB["Moonfire"], PlayerTarget)
    end
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
  and Spell.CanCast(SB["Thrash"], nil, nil, nil, false)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(SB["Thrash"])
  end
end

function DGPulverize()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Pulverize"], PlayerTarget)
  and Debuff.Stacks(PlayerTarget, AB["Thrash"]) >= 2 then
    return Spell.Cast(SB["Pulverize"], PlayerTarget)
  end
end

function DGMaul()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Maul"], PlayerTarget, 1, 45) then
    if Rage >= MaulRage
    and Unit.PercentHealth(PlayerUnit) >= MaulHealth then
      return Spell.Cast(SB["Maul"], PlayerTarget)
    end
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
