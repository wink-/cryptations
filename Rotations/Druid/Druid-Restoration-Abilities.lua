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

function DRTranquility()
end

function DRInnervate()
  if Spell.CanCast(29166) then
    return Spell.Cast(29166)
  end
end

function DRIronbark()
end

function DREoG()
end

function HoTCount()
  return RejuvenationCount() + getn(Buff.FindUnitsWith(33763, true))
end

function DRFlourish()
  if Spell.CanCast(197721) and HoTCount() >= 3 then
    return Spell.Cast(197721)
  end
end

function DREfflorescence()
end

function DRLifebloom()
  if MainTank ~= nil and Spell.CanCast(33763, MainTank, 0, MaxMana * 0.12)
  and Unit.IsInLOS(MainTank) then
    if not Buff.Has(MainTank, 33763, true)
    or select(3, Buff.Has(MainTank, 33763, true)) <= 4.5 then
      return Spell.Cast(33763, MainTank)
    end
  end
end

function DRRegrowthClearcast()
  if MainTank ~= nil and Spell.CanCast(8936, MainTank)
  and Buff.Has(PlayerUnit, 16870) and Unit.IsInLOS(MainTank) then
    return Spell.Cast(8936, MainTank)
  end
end

function DRRegrowth()
  local Target = Group.UnitToHeal()
  if Spell.CanCast(8936, Target, 0, MaxMana * 0.1863)
  and Unit.PercentHealth(Target) <= RegrowthHealth
  and Unit.IsInLOS(Target) then
    return Spell.Cast(8936, Target)
  end
end

function DRCenarionWard()
  if Spell.CanCast(102351, HealTarget, 0, MaxMana * 0.092)
  and Unit.IsInLOS(HealTarget) then
    return Spell.Cast(102351, HealTarget)
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
  if RejuvenationCount() < MaxRejuv
  and Spell.CanCast(774, Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(774, Target)
  end
end

function DRWildGrowth()
end

function DRSwiftmend()
end
