local ClassID = select(3, UnitClass("player"))
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
  if Spell.CanCast(740, nil, 0, MaxMana * 0.184)
  and Tranquility
  and Group.AverageHealth() <= TQHealth then
    return Spell.Cast(740)
  end
end

function DRInnervate()
  if Spell.CanCast(29166, PlayerUnit)
  and Innervate then
    return Spell.Cast(29166, PlayerUnit)
  end
end

function DRIronbark()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(102342, Target)
  and Unit.PercentHealth(Target) <= IBHealth then
    return Spell.Cast(102342, Target)
  end
end

function DREoG()
  if EoG
  and HoTCount() >= EoGHoTCount
  and Spell.CanCast(208253) then
    return Spell.Cast(208253)
  end
end

function HoTCount()
  return RejuvenationCount() + getn(Buff.FindUnitsWith(33763, true))
end

function DRFlourish()
  if Spell.CanCast(197721) and HoTCount() >= 3 then
    return Spell.Cast(197721)
  end
end

function EfflorescencePos()
  return Unit.GetCenterBetweenUnits(Group.FindBestToHeal(10, EFUnits, EFHealth))
end

function EfflorescenceReplace()
  -- TODO: check if there are still players in the existing Efflorescence radius
  --        or if there is a group that is better to heal
end

function DREfflorescence()
  local x, y, z = EfflorescencePos()
  if x ~= nil and y ~= nil and z ~= nil
  and GetTotemInfo(1) == false
  and Spell.CanCast(145205, nil, 0, MaxMana * 0.216) then
    EFx = x
    EFy = y
    EFz = z
    return Spell.CastGroundSpell(145205, x, y, z)
  end
end

function DRLifebloom()
  local Target = Group.TankToHeal()
  if Target ~= nil
  and Spell.CanCast(33763, Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    if not Buff.Has(Target, 33763, true)
    or select(3, Buff.Has(Target, 33763, true)) <= LBTime then
      return Spell.Cast(33763, Target)
    end
  end
end

function DRRegrowthClearcast()
  local Target = Group.TankToHeal()
  if Target ~= nil
  and (Spell.GetPreviousSpell() ~= 8936 or Spell.GetTimeSinceLastSpell() >= 500)
  and Spell.CanCast(8936, Target)
  and Buff.Has(PlayerUnit, 16870)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(8936, Target)
  end
end

function DRRegrowth()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(8936, Target, 0, MaxMana * 0.1863)
  and Unit.PercentHealth(Target) <= RegrowthHealth
  and Unit.IsInLOS(Target) then
    return Spell.Cast(8936, Target)
  end
end

function DRCenarionWard()
  local Target = Group.UnitToHeal()
  if Spell.CanCast(102351, Target, 0, MaxMana * 0.092)
  and CenarionWard
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= CWHealth then
    return Spell.Cast(102351, Target)
  end
end

-- returns the count of rejuvenations applied by the player
function RejuvenationCount()
  return getn(Buff.FindUnitsWith(774, true))
end

-- returns the lowest unit that does not have a rejuvenation from the player on it
function RejuvenationTarget()
  for i = 1, getn(GROUP_MEMBERS) do
    if not Buff.Has(GROUP_MEMBERS[i], 774, true)
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
  and Spell.CanCast(774, Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(774, Target)
  end
end

function DRWildGrowth()
  local Target = Unit.FindBestToHeal(30, WGUnits, WGHealth)
  if Target ~= nil
  and Spell.CanCast(48438, Target, 0, MaxMana * 0.34)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(48438, Target)
  end
end

function DRSwiftmend()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(18562, Target, 0, MaxMana * 0.14)
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= SMHealth then
    return Spell.Cast(18562, Target)
  end
end

function DRHealingTouch()
  local Target = Group.UnitToHeal()
  if Target ~= nil
  and Spell.CanCast(5185, Target)
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= HTHealth then
    return Spell.Cast(5185, Target)
  end
end
