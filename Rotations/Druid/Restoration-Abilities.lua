local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 4 then return end
if FireHack == nil then return end

local Spell   = LibStub("Spell")
local Unit    = LibStub("Unit")
local Group   = LibStub("Group")
local Buff    = LibStub("Buff")
local Debuff  = LibStub("Debuff")

-- Efflorescence position
EFx, EFy, EFz = nil

function DRTranquility()
  if Spell.CanCast(SB["Tranquility"], nil, 0, MaxMana * 0.184)
  and Tranquility
  and Group.AverageHealth() <= TQHealth then
    return Spell.Cast(SB["Tranquility"])
  end
end

function DRInnervate()
  if Spell.CanCast(SB["Innervate"], PlayerUnit)
  and Innervate then
    return Spell.Cast(SB["Innervate"], PlayerUnit)
  end
end

function DRIronbark()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(SB["Ironbark"], Target)
  and Unit.PercentHealth(Target) <= IBHealth then
    return Spell.Cast(SB["Ironbark"], Target)
  end
end

function DREoG()
  if EoG
  and HoTCount() >= EoGHoTCount
  and Spell.CanCast(SB["Essence of G'Hanir"]) then
    return Spell.Cast(SB["Essence of G'Hanir"])
  end
end

function HoTCount()
  return RejuvenationCount() + #Buff.FindUnitsWith(33763, true)
end

function DRFlourish()
  if Spell.CanCast(SB["Flourish"]) and HoTCount() >= 3 then
    return Spell.Cast(SB["Flourish"])
  end
end

function EfflorescencePos()
  local Units = Group.FindBestToHeal(10, EFUnits, EFHealth, 40)
  if Units ~= nil then
    return Unit.GetCenterBetweenUnits(Units)
  end

  return nil
end

function EfflorescenceReplace()
  -- TODO: check if there are still players in the existing Efflorescence radius
  --        or if there is a group that is better to heal
end

function DREfflorescence()
  local x, y, z = EfflorescencePos()
  if x ~= nil and y ~= nil and z ~= nil
  and GetTotemInfo(1) == false
  and Spell.CanCast(SB["Efflorescence"], nil, 0, MaxMana * 0.216) then
    EFx = x
    EFy = y
    EFz = z
    return Spell.CastGroundSpell(SB["Efflorescence"], x, y, z)
  end
end

function DRLifebloom()
  local Target = Group.TankToHeal()
  if Target ~= nil
  and Spell.CanCast(SB["Lifebloom"], Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    if not Buff.Has(Target, AB["Lifebloom"], true)
    or Buff.RemainingTime(Target, AB["Lifebloom"], true) <= LBTime then
      return Spell.Cast(SB["Lifebloom"], Target)
    end
  end
end

function DRRegrowthClearcast()
  local Target = Group.TankToHeal()
  if Target ~= nil
  and (Spell.GetPreviousSpell() ~= SB["Regrowth"] or Spell.GetTimeSinceLastSpell() >= 500)
  and Spell.CanCast(SB["Regrowth"], Target)
  and Buff.Has(PlayerUnit, AB["Clearcasting"])
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Regrowth"], Target)
  end
end

function DRRegrowth()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(SB["Regrowth"], Target, 0, MaxMana * 0.1863)
  and Unit.PercentHealth(Target) <= RegrowthHealth
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Regrowth"], Target)
  end
end

function DRCenarionWard()
  local Target = Group.UnitToHeal()
  if Spell.CanCast(SB["Cenarion Ward"], Target, 0, MaxMana * 0.092)
  and CenarionWard
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= CWHealth then
    return Spell.Cast(SB["Cenarion Ward"], Target)
  end
end

-- returns the count of rejuvenations applied by the player
function RejuvenationCount()
  return #Buff.FindUnitsWith(AB["Rejuvenation"], true)
end

-- returns the lowest unit that does not have a rejuvenation from the player on it
function RejuvenationTarget()
  for i = 1, #GROUP_MEMBERS do
    if not Buff.Has(GROUP_MEMBERS[i], AB["Rejuvenation"], true)
    and Unit.PercentHealth(GROUP_MEMBERS[i]) <= RejuvHealth then
      return GROUP_MEMBERS[i]
    end
  end
end

-- applies Rejuvenation until the maximum Rejuvenation count
function DRRejuvenation()
  local Target = RejuvenationTarget()
  if Target ~= nil
  and RejuvenationCount() < MaxRejuv
  and Spell.CanCast(SB["Rejuvenation"], Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Rejuvenation"], Target)
  end
end

function DRWildGrowth()
  local Target = Unit.FindBestToHeal(30, WGUnits, WGHealth, 40)
  if Target ~= nil
  and Spell.CanCast(SB["Wild Growth"], Target, 0, MaxMana * 0.34)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Wild Growth"], Target)
  end
end

function DRSwiftmend()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(SB["Swiftmend"], Target, 0, MaxMana * 0.14)
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= SMHealth then
    return Spell.Cast(SB["Swiftmend"], Target)
  end
end

function DRHealingTouch()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(SB["Healing Touch"], Target)
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= HTHealth then
    return Spell.Cast(SB["Healing Touch"], Target)
  end
end
