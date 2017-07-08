local Unit = LibStub:NewLibrary("Unit", 1)

PlayerTarget = nil                                 -- The unit which the player is targeting
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

-- produces true if the facing angle between player and unit is smaller or equal to given angle
function Unit.IsFacing(unit, angle)
  if unit == nil or angle == nil then
    return nil
  end

  local MyAngle = ObjectFacing(PlayerUnit)
  local MyAngleToUnit = select(1, GetAnglesBetweenObjects(PlayerUnit, unit))
  local AnglesDifference = MyAngle > MyAngleToUnit and MyAngle - MyAngleToUnit or MyAngleToUnit - MyAngle
  local AnglesBetweenUnits = AnglesDifference < math.pi and AnglesDifference or math.pi * 2 - AnglesDifference
  local FinalAngle = AnglesBetweenUnits / math.pi * 360

  return FinalAngle <= angle
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
  if IsSpellInRange(select(1, GetSpellInfo(spell)), unit) == 1 then
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
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and Unit.PercentHealth(Object) < healthPercent
    and ((range == nil and unit == nil) or Unit.IsInRange(unit, Object, range)) then
      if mode == "friendly" and ((not Unit.IsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      elseif mode == "hostile" and Unit.IsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      end
    end
  end
  return Units
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
  for i = 1, getn(DungeonBosses) do
    if Unit.GetCreatureID(unit) == DungeonBosses[i] then
      return true
    end
  end

  -- Raid Bosses
  for i = 1, getn(RaidBosses) do
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
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and (Highest == nil or Unit.PercentHealth(Object) > Unit.PercentHealth(Highest)) then
      if mode == "friendly" and ((not Unit.IsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Highest = Object
      elseif mode == "hostile" and Unit.IsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
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
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and (Lowest == nil or Unit.PercentHealth(Object) < Unit.PercentHealth(Lowest))
    and UnitHealth(Object) > 1 then
      if mode == "friendly" and ((not Unit.IsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Lowest = Object
      elseif mode == "hostile" and Unit.IsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
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
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and (Nearest == nil or GetDistanceBetweenObjects(otherUnit, Object) < GetDistanceBetweenObjects(otherUnit, Nearest))
    and UnitHealth(Object) > 1 and Object ~= PlayerUnit then
      if mode == "friendly" and ((not Unit.IsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Nearest = Object
      elseif mode == "hostile" and Unit.IsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
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
  if select(6, UnitCastingInfo(unit)) == nil
  or GetTime() * 1000 >= select(6, UnitCastingInfo(unit)) - (PreCastTime * 1000) then
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

  if select(6, UnitChannelInfo(unit)) == nil then
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

  local ObjectCount = GetObjectCount()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and Unit.IsInRange(otherUnit, Object, radius)
    and UnitHealth(Object) > 1 then
      if mode == "friendly" and ((not Unit.IsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      elseif mode == "hostile" and Unit.IsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
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

  local ObjectCount = GetObjectCount()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and Unit.IsFacing(Object, angle) and Unit.IsInRange(otherUnit, Object, distance)
    and UnitHealth(Object) > 1 and (healthPercent == nil or Unit.PercentHealth(Object) <= healthPercent) then
      if mode == "friendly" and ((not Unit.IsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      elseif mode == "hostile" and Unit.IsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
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

  local CastTime = nil
  local PercentCasted = nil

  if select(5, UnitCastingInfo(unit)) ~= nil then
    CastTime = select(6,  UnitCastingInfo(unit)) - select(5,  UnitCastingInfo(unit))
    PercentCasted = math.floor((1 - (select(6,  UnitCastingInfo(unit)) - GetTime() * 1000) / CastTime) * 100)
  end
  return PercentCasted
end

-- This is not tested well and might not work as expected
-- produces the time to die for the given unit
function Unit.ComputeTTD(unit)
  if unit == nil or not ObjectExists(unit) or Unit.IsDummy(unit) then
    return 9999
  end

  -- check if the unit is already known to the ttd table
  for i = 1, getn(TTD_TABLE) do
    if TTD_TABLE[i].unit == unit then
      -- update values
      TTD_TABLE[i].duration = GetTime() - TTD_TABLE[i].start
      TTD_TABLE[i].dps = (UnitHealthMax(TTD_TABLE[i].unit) - UnitHealth(TTD_TABLE[i].unit)) / TTD_TABLE[i].duration
      TTD_TABLE[i].ttd = UnitHealth(TTD_TABLE[i].unit) / TTD_TABLE[i].dps

      return TTD_TABLE[i].ttd
    end
  end

  -- add the unit to the ttd table
  local Entry = {unit = unit, start = GetTime(), duration = 0, dps = 0, ttd = 0}
  table.insert(TTD_TABLE, Entry)
  return 9999
end

-- returns the ID of the given unit (must be a creature)
function Unit.GetCreatureID(unit)
  -- catch errors
  if unit == nil or not ObjectExists(unit) then
    return nil
  end

  local guid = UnitGUID(unit)
  local type = select(1, strsplit("-", guid))

  -- catch invalid units
  if type ~= "Creature" then
    return nil
  end

  local creatureID = select(6, strsplit("-", guid))
  return tonumber(creatureID)
end

-- returns the center (x, y, z coordinates) between the units in the given table
-- at least two units required
function Unit.GetCenterBetweenUnits(units)
  local centerx, centery, centerz = 0, 0, 0
  local count = 0
  for i = 1, getn(units) do
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

  for i = 1, getn(TrainingDummies) do
    if Unit.GetCreatureID(unit) == TrainingDummies[i] then
      return true
    end
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
  for i = 1, getn(LossOfControlAuras) do
    if Debuff.Has(unit, LossOfControlAuras[i]) then
      return false
    end
  end

  return true
end

-- given a unit, returns table of all of the unit's buff id's
function Unit.GetBuffs(unit)
  Buffs = {}
  BuffCount = Buff.GetBuffCount(unit)
  for i = 1, BuffCount do
    table.insert(Buffs, select(11, UnitBuff(unit, i)))
  end
  return Buffs
end

-- given a unit, returns table of all of the unit's debuff id's
function Unit.GetDebuffs(unit)
  Debuffs = {}
  DebuffCount = Debuff.GetCount(unit)
  for i = 1, DebuffCount do
    table.insert(Debuffs, select(11, UnitDebuff(unit, i)))
  end
  return Debuffs
end
