local Unit = LibStub("Unit")
local Group = LibStub("Group")
local Player = LibStub("Player")

Spelltarget  = nil                                 -- The unit on which a spell shall be casted
TTD_TABLE    = {unit, start, duration, dps, ttd}   -- Holds the values required for calculating the ttd

-- returns true if a given unit is hostile and therefore can be attacked
function Unit.IsHostile(unit)
  if unit == nil then
    return nil
  end

  if (UnitIsEnemy(PlayerUnit, unit) or UnitCanAttack(PlayerUnit, unit)) then
    return true
  else
    return false
  end
end

-- returns true if given unit is in player's los
function Unit.IsInLOS(unit)
  if unit == nil then
    return nil
  end

  if not ObjectExists(unit) then
    return nil
  end

  local px, py, pz = ObjectPosition(PlayerUnit)
  local ux, uy, uz = ObjectPosition(unit)

  return TraceLine(px, py, pz + 2, ux, uy, uz + 2, 0x10) == nil
end

-- returns true if distance between unit and otherunit
-- is lower or equal to given distance
function Unit.IsInRange(unit, otherUnit, distance)
  if unit == nil or otherUnit == nil then
    return nil
  end

  return GetDistanceBetweenObjects(unit, otherUnit) <= distance
end

-- same as IsInRange but this one considers the boundingboxes and combat reach
function Unit.IsInAttackRange(spell, unit)
  if unit == nil then
    return nil
  end

  -- for casted spells
  local Name = GetSpellInfo(spell)
  if IsSpellInRange(Name, unit) == 1 then
    return true
  end
  -- for melee
  if GetDistanceBetweenObjects(PlayerUnit, unit) <= UnitCombatReach(PlayerUnit) + UnitCombatReach(unit) + 4/3 then
    return true
  end
  return false
end

-- returns true if given unit is moving (in any direction)
function Unit.IsMoving(unit)
  if unit == nil then
    return nil
  end

  return UnitMovementFlags(unit) ~= 0
end

-- returns table containing units that are below the given health percentage
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
-- unit (optional) : needed for range
-- range (optional) : the range which shall be scanned for units
function Unit.GetUnitsBelowHealth(healthPercent, mode, onlyCombat, unit, range)
  local Units = {}

  -- for hostile units
  if mode == "hostile" then
    for Object, _ in pairs(UNIT_TRACKER) do
      if ObjectExists(Object)
      --and (unit == nil or Object ~= unit)
      and Unit.PercentHealth(Object) < healthPercent
      and ((range == nil and unit == nil) or Unit.IsInRange(unit, Object, range))
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      end
    end
  end

  -- for group units
  if mode == "friendly" then
    for i = 1, #GROUP_MEMBERS do
      local Object = GROUP_MEMBERS[i]
      if ObjectExists(Object)
      --and (unit == nil or Object ~= unit)
      and Unit.PercentHealth(Object) < healthPercent
      and ((range == nil and unit == nil) or Unit.IsInRange(unit, Object, range))
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      end
    end
  end

  return Units
end

-- returns true if the first unit is the second unit's primary target
function Unit.IsTanking(unit, otherUnit)
  local IsTanking = UnitDetailedThreatSituation(unit, otherUnit)
  return IsTanking ~= nil
end

-- returns true when the given unit is tanking a boss
function Unit.IsTankingBoss(unit)
  if unit == nil then
    return nil
  end

  local Target = UnitTarget(unit)
  if Unit.IsBoss(Target) then
    return true
  end

  return false
end

-- returns true if the given unit is a boss (depends on hardcoded list)
function Unit.IsBoss(unit)
  if unit == nil or not ObjectExists(unit) then
    return nil
  end

  -- Dungeon Bosses
  for i = 1, #DungeonBosses do
    if Unit.GetCreatureID(unit) == DungeonBosses[i] then
      return true
    end
  end

  -- Raid Bosses
  for i = 1, #RaidBosses do
    if Unit.GetCreatureID(unit) == RaidBosses[i] then
      return true
    end
  end

  return false
end

-- returns the percent value of the unit's current health
function Unit.PercentHealth(unit)
  if unit == nil then
    return nil
  end

  return math.floor((UnitHealth(unit) / UnitHealthMax(unit)) * 100)
end

-- return the unit with the most health percentage
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
function Unit.FindHighest(mode, onlyCombat)
  local Highest = nil

  if mode == 'hostile' then
    for Object, _ in pairs(UNIT_TRACKER) do
      if ObjectExists(Object)
      and (Highest == nil or Unit.PercentHealth(Object) > Unit.PercentHealth(Highest))
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        Highest = Object
      end
    end
  end

  if mode == 'friendly' then
    for i = 1, #GROUP_MEMBERS do
      local Object = GROUP_MEMBERS[i]

      if ObjectExists(Object)
      and (Highest == nil or Unit.PercentHealth(Object) > Unit.PercentHealth(Highest))
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        Highest = Object
      end
    end
  end

  return Highest
end

-- return the unit with the least health percentage
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
function Unit.FindLowest(mode, onlyCombat)
  local Lowest = nil

  if mode == 'hostile' then
    for Object, _ in pairs(UNIT_TRACKER) do
      if ObjectExists(Object)
      and (Lowest == nil or Unit.PercentHealth(Object) < Unit.PercentHealth(Lowest))
      and UnitHealth(Object) > 1
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        Lowest = Object
      end
    end
  end

  if mode == 'friendly' then
    for i = 1, #GROUP_MEMBERS do
      local Object = GROUP_MEMBERS[i]

      if ObjectExists(Object)
      and (Lowest == nil or Unit.PercentHealth(Object) < Unit.PercentHealth(Lowest))
      and UnitHealth(Object) > 1
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        Lowest = Object
      end
    end
  end

  return Lowest
end

-- return the unit which is closest to the given unit
-- ignores dead units
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
function Unit.FindNearest(otherUnit, mode, onlyCombat)
  if otherUnit == nil then
    return nil
  end

  local Nearest = nil

  if mode == 'hostile' then
    for Object, _ in pairs(UNIT_TRACKER) do
      if ObjectExists(Object)
      and Object ~= PlayerUnit
      and (Nearest == nil
      or GetDistanceBetweenObjects(otherUnit, Object) < GetDistanceBetweenObjects(otherUnit, Nearest))
      and UnitHealth(Object) > 1
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        Nearest = Object
      end
    end
  end

  if mode == 'friendly' then
    for i = 1, #GROUP_MEMBERS do
      local Object = GROUP_MEMBERS[i]

      if ObjectExists(Object)
      and Object ~= PlayerUnit
      and (Nearest == nil
      or GetDistanceBetweenObjects(otherUnit, Object) < GetDistanceBetweenObjects(otherUnit, Nearest))
      and UnitHealth(Object) > 1
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        Nearest = Object
      end
    end
  end

  return Nearest
end

-- returns true if unit is currently casting a spell
function Unit.IsCasting(unit)
  if unit == nil then
    return nil
  end

  local _, _, _, _, _, EndTime = UnitCastingInfo(unit)
  if EndTime == nil
  or GetTime() * 1000 >= EndTime - (PreCastTime * 1000) then
    return false
  else
    return true
  end
end

-- returns true if unit is currently channeling a spell
function Unit.IsChanneling(unit)
  if unit == nil or not ObjectExists(unit) then
    return nil
  end

  local _, _, _, _, _, EndTime = UnitChannelInfo(unit)
  if EndTime == nil
  or GetTime() * 1000 >= EndTime - (PreCastTime * 1000) then
    return false
  else
    return true
  end
end

-- returns table containing units that are within the given radius of the given unit
-- ignores dead units
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
function Unit.GetUnitsInRadius(otherUnit, radius, mode, onlyCombat)
  if otherUnit == nil then
    return nil
  end

  local Units = {}

  -- for hostile units
  if mode == "hostile" then
    for Object, _ in pairs(UNIT_TRACKER) do
      if Object ~= otherUnit
      and Unit.IsInRange(otherUnit, Object, radius)
      and UnitHealth(Object) > 1 then
        if (onlyCombat ~= true or (UnitAffectingCombat(Object) or Unit.IsDummy(Object))) then
          table.insert(Units, Object)
        end
      end
    end
  end

  -- for friendly units
  if mode == "friendly" then
    for i = 1, #GROUP_MEMBERS do
      local Object = GROUP_MEMBERS[i]
      if Object ~= otherUnit
      and Unit.IsInRange(otherUnit, Object, radius)
      and UnitHealth(Object) > 1
      and (onlyCombat ~= true or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      end
    end
  end

  return Units
end

-- returns table containing units that are within the given unit's given cone angle and distance
-- ignores dead units
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
-- healthPercent (optional) : only units below or equal to this threshold will be added
function Unit.GetUnitsInCone(otherUnit, angle, distance, mode, onlyCombat, healthPercent)
  if otherUnit == nil then
    return nil
  end

  local Units = {}

  -- for hostile units
  if mode == "hostile" then
    for Object, _ in pairs(UNIT_TRACKER) do
      if ObjectExists(Object)
      and Object ~= otherUnit
      and Player.IsFacing(Object, angle)
      and Unit.IsInRange(otherUnit, Object, distance)
      and UnitHealth(Object) > 1
      and (healthPercent == nil or Unit.PercentHealth(Object) <= healthPercent) then
        if onlyCombat ~= true or (UnitAffectingCombat(Object) or Unit.IsDummy(Object)) then
          table.insert(Units, Object)
        end
      end
    end
  end

  if mode == "friendly" then
    for i = 1, #GROUP_MEMBERS do
      local Object = GROUP_MEMBERS[i]
      if ObjectExists(Object)
      and Object ~= otherUnit
      and Player.IsFacing(Object, angle)
      and Unit.IsInRange(otherUnit, Object, distance)
      and UnitHealth(Object) > 1
      and (healthPercent == nil or Unit.PercentHealth(Object) <= healthPercent)
      and (onlyCombat ~= true or (UnitAffectingCombat(Object))) then
        table.insert(Units, Object)
      end
    end
  end

  return Units
end

-- returns the percent value of the unit's spellcast progress
function Unit.CastedPercent(unit)
  if unit == nil then
    return nil
  end

  local PercentCasted = nil

  local _, _, _, _, StartTime, EndTime = UnitCastingInfo(unit)
  if StartTime ~= nil then
    local CastTime = EndTime - StartTime
    PercentCasted = math.floor((1 - (EndTime - GetTime() * 1000) / CastTime) * 100)
  end

  return PercentCasted
end

-- returns the ID of the given unit (must be a creature)
function Unit.GetCreatureID(unit)
  -- catch errors
  if unit == nil or not ObjectExists(unit) then
    return nil
  end

  local guid = UnitGUID(unit)
  local type = strsplit("-", guid)

  -- catch invalid units
  if type ~= "Creature" then
    return nil
  end

  local _, _, _, _, _, creatureID = strsplit("-", guid)
  return tonumber(creatureID)
end

-- returns the center (x, y, z coordinates) between the units in the given table
-- at least two units required
function Unit.GetCenterBetweenUnits(units)
  local centerx, centery, centerz = 0, 0, 0
  local count = 0
  for i = 1, #units do
    unitx, unity, unitz = ObjectPosition(units[i])
    centerx = centerx + unitx
    centery = centery + unity
    centerz = centerz + unitz
    count = count + 1
  end
  return centerx / count, centery / count, centerz / count
end

-- returns true if the given unit is a training dummy
function Unit.IsDummy(unit)
  if unit == nil then
    return nil
  end

  local Name = ObjectName(unit)
  if strfind(strlower(Name), "dummy") ~= nil then
    return true
  end

  return false
end

-- returns whether or not the unit has control (stunned, silenced, ...)
-- this can only recognize if a unit was stunned, feared, etc. by a player
function Unit.HasControl(unit)
  if unit == nil or not ObjectExists(unit) then
    return nil
  end

  -- Use wowfunction for player
  if unit == PlayerUnit then
    return HasFullControl()
  end

  -- Check if affected by crowdcontrol spell
  for i = 1, #LossOfControlAuras do
    if Debuff.Has(unit, LossOfControlAuras[i]) then
      return false
    end
  end

  return true
end

-- given a unit, returns table of all of the unit's buff id's
function Unit.GetBuffs(unit)
  Buffs = {}
  for i = 1, 50 do
    local _, _, _, _, _, _, _, _, _, _, ID = UnitBuff(unit, i)
    if ID ~= nil then
      table.insert(Buffs, ID)
    end
  end

  return Buffs
end

-- given a unit, returns table of all of the unit's debuff id's
function Unit.GetDebuffs(unit)
  Debuffs = {}
  for i = 1, 50 do
    local _, _, _, _, _, _, _, _, _, _, ID = UnitDebuff(unit, i)
    if ID ~= nil then
      table.insert(Debuffs, ID)
    end
  end

  return Debuffs
end

-- returns the unit that is best to heal for the given parameters
function Unit.FindBestToHeal(range, minUnits, health, maxDistance)
  local BestTarget        = nil
  local UnitCountBest     = 0
  local UnitCountCurrent  = 0
  local GroupHealth       = 100
  local CurrentUnit       = nil
  for i = 1, #GROUP_MEMBERS do
    CurrentUnit = GROUP_MEMBERS[i]
    Units = Unit.GetUnitsBelowHealth(health, "friendly", true, CurrentUnit, range)
    if Unit.PercentHealth(CurrentUnit) <= health then
      table.insert(Units, CurrentUnit)
    end
    UnitCountCurrent = #Units
    if Unit.IsInRange(CurrentUnit, PlayerUnit, maxDistance)
    and UnitCountCurrent >= minUnits
    and UnitCountCurrent > UnitCountBest
    and Group.AverageHealthCustom(Units) <= GroupHealth then
      UnitCountBest = UnitCountCurrent
      BestTarget = CurrentUnit
      GroupHealth = Group.AverageHealthCustom(Units)
    end
  end

  return BestTarget
end

-- returns the unit that is best to cast aoe on for the given parameters
function Unit.FindBestToAOE(range, minUnits, maxDistance)
  local BestTarget        = nil
  local UnitCountBest     = 0
  local UnitCountCurrent  = 0
  for Object, _ in pairs(UNIT_TRACKER) do
    if ObjectIsType(Object, ObjectTypes.Unit)
    and ObjectExists(Object)
    and Unit.IsInRange(Object, PlayerUnit, maxDistance)
    and (UnitAffectingCombat(Object) or Unit.IsDummy(Object))
    and Unit.IsInLOS(Object) then
      UnitCountCurrent = #Unit.GetUnitsInRadius(Object, range, "hostile", true) + 1
      if UnitCountCurrent >= minUnits
      and UnitCountCurrent > UnitCountBest then
        UnitCountBest = UnitCountCurrent
        BestTarget = Object
      end
    end
  end

  return BestTarget
end

-- returns true when the given unit currently casts the given spellID
function Unit.IsCastingSpecific(unit, spellID)
  local _, _, _, _, _, _, _, castID = UnitCastingInfo(unit)
  return castID == spellID
end
