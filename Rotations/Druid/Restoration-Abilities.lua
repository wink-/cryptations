local DruidRestoration  = LibStub("DruidRestoration")
local Spell             = LibStub("Spell")
local Unit              = LibStub("Unit")
local Group             = LibStub("Group")
local Buff              = LibStub("Buff")
local Debuff            = LibStub("Debuff")

-- Efflorescence position
EFx, EFy, EFz = nil

function DruidRestoration.Tranquility()
  if Spell.CanCast(SB["Tranquility"], nil, 0, MaxMana * 0.184)
  and Tranquility
  and not Unit.IsMoving(PlayerUnit)
  and Group.AverageHealth() <= TQHealth then
    return Spell.Cast(SB["Tranquility"])
  end
end

function DruidRestoration.Innervate()
  if Spell.CanCast(SB["Innervate"], PlayerUnit)
  and Innervate then
    return Spell.Cast(SB["Innervate"], PlayerUnit)
  end
end

function DruidRestoration.Ironbark()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and Spell.CanCast(SB["Ironbark"], Target)
  and Unit.PercentHealth(Target) <= IBHealth then
    return Spell.Cast(SB["Ironbark"], Target)
  end
end

function DruidRestoration.EoG()
  if EoG
  and Group.AverageHealth() <= EoGHealth
  and Spell.CanCast(SB["Essence of G'Hanir"]) then
    return Spell.Cast(SB["Essence of G'Hanir"])
  end
end

function DruidRestoration.HoTCount()
  return (DruidRestoration.RejuvenationCount()
  + #Buff.FindUnitsWith(AB["Lifebloom"], true, true)
  + #Buff.FindUnitsWith(AB["Wild Growth"], true, true)
  + #Buff.FindUnitsWith(AB["Regrowth"], true, true)
  + #Buff.FindUnitsWith(AB["Living Seed"], true, true))
end

function DruidRestoration.Flourish()
  if Flourish
  and DruidRestoration.HoTCount() >= FLHoTCount
  and Spell.CanCast(SB["Flourish"]) then
    return Spell.Cast(SB["Flourish"])
  end
end

function DruidRestoration.EfflorescencePos()
  local Units = Group.FindBestToHeal(10, EFUnits, EFHealth, 40)

  if Units ~= nil then
    return Unit.GetCenterBetweenUnits(Units)
  end

  return nil
end

function DruidRestoration.EfflorescenceReplace()
  -- TODO: check if there are still players in the existing Efflorescence radius
  --        or if there is a group that is better to heal
end

function DruidRestoration.Efflorescence()
  local x, y, z = ObjectPosition(Unit.FindBestToHeal(15, EFUnits, EFHealth, 40))

  if x ~= nil and y ~= nil and z ~= nil
  and GetTotemInfo(1) == false
  and Spell.CanCast(SB["Efflorescence"], nil, 0, MaxMana * 0.216) then
    EFx = x
    EFy = y
    EFz = z
    return Spell.CastGroundSpell(SB["Efflorescence"], x, y, z)
  end
end

function DruidRestoration.Lifebloom()
  local Target = Group.TankToHeal()

  if Target ~= nil
  and Spell.CanCast(SB["Lifebloom"], Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target) then
    if not Buff.Has(Target, AB["Lifebloom"], true)
    or Buff.RemainingTime(Target, AB["Lifebloom"], true) <= 5 then
      return Spell.Cast(SB["Lifebloom"], Target)
    end
  end
end

function DruidRestoration.RegrowthClearcast()
  local Target = Group.TankToHeal()

  if Target ~= nil
  and (Spell.GetPreviousSpell() ~= SB["Regrowth"] or Spell.GetTimeSinceLastSpell() >= 500)
  and Spell.CanCast(SB["Regrowth"], Target)
  and Buff.Has(PlayerUnit, AB["Clearcasting"])
  and Unit.IsInLOS(Target) then
    return Spell.AddToQueue(SB["Regrowth"], Target)
  end
end

function DruidRestoration.Regrowth()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and Spell.CanCast(SB["Regrowth"], Target, 0, MaxMana * 0.1863)
  and Unit.PercentHealth(Target) <= RegrowthHealth
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Regrowth"], Target)
  end
end

function DruidRestoration.CenarionWard()
  local Target = Group.TankToHeal()

  if Target ~= nil
  and CenarionWard
  and Spell.CanCast(SB["Cenarion Ward"], Target, 0, MaxMana * 0.092)
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= CWHealth then
    return Spell.Cast(SB["Cenarion Ward"], Target)
  end
end

-- returns the count of rejuvenations applied by the player
function DruidRestoration.RejuvenationCount()
  return #Buff.FindUnitsWith(AB["Rejuvenation"], true, true)
end

-- returns the lowest unit that does not have a rejuvenation from the player on it
function DruidRestoration.RejuvenationTarget()
  -- Update sorted Heal Priority
  Group.HealPriority()

  -- normal rejuvenation
  for i = 1, #GROUP_MEMBERS do
    if (not Buff.Has(GROUP_MEMBERS[i], AB["Rejuvenation"], true)
    or Buff.RemainingTime(GROUP_MEMBERS[i], AB["Rejuvenation"], true) <= 5)
    and Unit.PercentHealth(GROUP_MEMBERS[i]) <= RejuvHealth then
      return GROUP_MEMBERS[i]
    end
  end

  -- germination
  for i = 1, #GROUP_MEMBERS do
    if (not Buff.Has(GROUP_MEMBERS[i], AB["Rejuvenation (Germination)"], true)
    or Buff.RemainingTime(GROUP_MEMBERS[i], AB["Rejuvenation (Germination)"], true) <= 5)
    and Unit.PercentHealth(GROUP_MEMBERS[i]) <= GermHealth then
      return GROUP_MEMBERS[i]
    end
  end
end

-- applies Rejuvenation until the maximum Rejuvenation count
function DruidRestoration.Rejuvenation()
  local Target = DruidRestoration.RejuvenationTarget()

  if Target ~= nil
  and DruidRestoration.RejuvenationCount() < MaxRejuv
  and Spell.CanCast(SB["Rejuvenation"], Target, 0, MaxMana * 0.1)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Rejuvenation"], Target)
  end
end

function DruidRestoration.WildGrowth()
  local Target = Unit.FindBestToHeal(30, WGUnits, WGHealth, 40)

  if Target ~= nil
  and Spell.CanCast(SB["Wild Growth"], Target, 0, MaxMana * 0.34)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Wild Growth"], Target)
  end
end

function DruidRestoration.Swiftmend()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and Spell.CanCast(SB["Swiftmend"], Target, 0, MaxMana * 0.14)
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= SMHealth then
    return Spell.Cast(SB["Swiftmend"], Target)
  end
end

function DruidRestoration.HealingTouch()
  local Target = Group.UnitToHeal()

  if Target ~= nil
  and Spell.CanCast(SB["Healing Touch"], Target)
  and Unit.IsInLOS(Target)
  and Unit.PercentHealth(Target) <= HTHealth then
    return Spell.Cast(SB["Healing Touch"], Target)
  end
end

function DruidRestoration.Incarnation()
  if Spell.CanCast(SB["Incarnation: Tree of Life"])
  and Incarnation
  and not Buff.Has(PlayerUnit, AB["Incarnation: Tree of Life"])
  and Group.AverageHealth() <= IncarHealth then
    Spell.Cast(SB["Incarnation: Tree of Life"])
  end
end

function DruidRestoration.Renewal()
  if Spell.CanCast(SB["Renewal"])
  and Renewal
  and Unit.PercentHealth(PlayerUnit) <= RWHealth then
    return Spell.Cast(SB["Renewal"])
  end
end

function DruidRestoration.SolarWrath()
  local Target = PlayerTarget()

  if Target ~= nil
  and DPS
  and Spell.CanCast(SB["Solar Wrath Restoration"], Target) then
    Spell.Cast(SB["Solar Wrath Restoration"], Target)
  end
end

function DruidRestoration.VFS()

end
