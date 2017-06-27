-- returns true if a given unit is hostile and therefore can be attacked
function ct.UnitIsHostile(unit)
  if unit == nil then
    return nil
  end

  if (UnitIsEnemy(ct.player, unit) or UnitCanAttack(ct.player, unit)) then
    return true
  else
    return false
  end
end

-- several checks to determine whether or not a spell can be casted
-- returns true if all checks pass
-- checkIfKnown (optional) : if true, checks if the spell is known
function ct.CanCast(spell, unit, powerType, power, checkIfKnown)
  return select(1, GetSpellCooldown(spell)) == 0 and (unit == nil or ct.IsInAttackRange(spell, unit))
  and (IsSpellKnown(spell) or checkIfKnown == false)
  and ((powerType == nil and power == nil) or UnitPower(ct.player, powerType) >= power)
end

-- produces true if the facing angle between player and unit is smaller or equal to given angle
function ct.IsFacing(unit, angle)
  if unit == nil then
    return nil
  end

  local MyAngle = ObjectFacing(ct.player)
  local MyAngleToUnit = select(1, GetAnglesBetweenObjects(ct.player, unit))
  local AnglesDifference = MyAngle > MyAngleToUnit and MyAngle - MyAngleToUnit or MyAngleToUnit - MyAngle
  local AnglesBetweenUnits = AnglesDifference < math.pi and AnglesDifference or math.pi * 2 - AnglesDifference
  local FinalAngle = AnglesBetweenUnits / math.pi * 360

  return FinalAngle <= angle
end

-- returns true if given unit is in player's los
function ct.IsInLOS(unit)
  if unit == nil then
    return nil
  end

  if not ObjectExists(unit) then
    return nil
  end

  local px, py, pz = ObjectPosition(ct.player)
  local ux, uy, uz = ObjectPosition(unit)

  return TraceLine(px, py, pz + 2, ux, uy, uz + 2, 0x10) == nil
end

-- returns true if distance between unit and otherunit
-- is lower or equal to given distance
function ct.IsInRange(unit, otherUnit, distance)
  if unit == nil or otherUnit == nil then
    return nil
  end

  return GetDistanceBetweenObjects(unit, otherUnit) <= distance
end

-- same as above but this one considers the boundingboxes and combat reach
function ct.IsInAttackRange(spell, unit)
  if unit == nil then
    return nil
  end

  -- for casted spells
  if IsSpellInRange(select(1, GetSpellInfo(spell)), unit) == 1 then
    return true
  end
  -- for melee
  if GetDistanceBetweenObjects(ct.player, unit) <= UnitCombatReach(ct.player) + UnitCombatReach(unit) + 4/3 then
    return true
  end
  return false
end

-- returns true if given unit is moving (in any direction)
function ct.UnitIsMoving(unit)
  if unit == nil then
    return nil
  end

  return UnitMovementFlags(unit) ~= 0
end

-- returns true if player can cast while moving (e.g. ice floes)
-- or if given spell can be casted while moving (e.g. instant cast, scorch, ...)
function ct.CanCastWhileMoving(spell)
  -- check if player is affected by auras that allow casting while moving
  for i, v in ipairs(ct.CastWhileMovingAuras) do
    if ct.UnitHasAura(ct.player, ct.CastWhileMovingAuras[i]) then
      return true
    end
  end

  -- check if player is casting a spell that can be casted while moving
  for i, v in ipairs(ct.CastWhileMovingSpells) do
    if spell == ct.CastWhileMovingSpells[i] then
      return true
    end
  end

  -- check if a spell is instant cast
  if select(4, GetSpellInfo(spell)) == 0 then
    return true
  else
    return false
  end
end

-- given an unit and an auraID, produces true if unit has aura
function ct.UnitHasAura(unit, auraID)
  if unit == nil then
    return nil
  end

  local AuraCount = ct.GetAuraCount(unit)

  -- iterate over unit's auras
  for i = 1, AuraCount do
    if select(11, UnitAura(unit, i)) == auraID then
      return true
    end
  end

  return false
end

-- returns number of how many auras the given unit has
function ct.GetAuraCount(unit)
  if unit == nil then
    return nil
  end

  local AuraIndex = 1
  local AuraCount = 0

  while (select(1, UnitAura(unit, AuraIndex))) do
    AuraIndex = AuraIndex + 1
    AuraCount = AuraCount + 1
  end
  return AuraCount
end

-- returns table containing every unit that has the given aura
function ct.FindUnitsWithAura(auraID)
  local ObjectCount = GetObjectCount ()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and ct.UnitHasAura(Object, auraID) then
      table.insert(Units, Object)
    end
  end
  return Units
end

-- return the unit with the most health percentage
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
function ct.FindHighestUnit(mode, onlyCombat)
  local Highest = nil
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and (Highest == nil or ct.PercentHealth(Object) > ct.PercentHealth(Highest)) then
      if mode == "friendly" and ((not ct.UnitIsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Highest = Object
      elseif mode == "hostile" and ct.UnitIsHostile(Object)
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
function ct.FindLowestUnit(mode, onlyCombat)
  local Lowest = nil
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and (Lowest == nil or ct.PercentHealth(Object) < ct.PercentHealth(Lowest))
    and UnitHealth(Object) > 1 then
      if mode == "friendly" and ((not ct.UnitIsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Lowest = Object
      elseif mode == "hostile" and ct.UnitIsHostile(Object)
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
function ct.FindNearestUnit(otherUnit, mode, onlyCombat)
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
    and UnitHealth(Object) > 1 and Object ~= ct.player then
      if mode == "friendly" and ((not ct.UnitIsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Nearest = Object
      elseif mode == "hostile" and ct.UnitIsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Nearest = Object
      end
    end
  end
  return Nearest
end

-- returns true if player is currently casting a spell
function ct.IsCasting(unit)
  if unit == nil then
    return nil
  end
  if select(6, UnitCastingInfo(unit)) == nil
  or GetTime() * 1000 >= select(6, UnitCastingInfo(unit)) - ct.CastDelay then
    return false
  else
    return true
  end
end

-- returns table containing units that are within the given radius of the given unit
-- ignores dead units
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
function ct.GetUnitsInRadius(otherUnit, radius, mode, onlyCombat)
  if otherUnit == nil then
    return nil
  end

  local ObjectCount = GetObjectCount()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and ct.IsInRange(otherUnit, Object, radius)
    and UnitHealth(Object) > 1 then
      if mode == "friendly" and ((not ct.UnitIsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      elseif mode == "hostile" and ct.UnitIsHostile(Object)
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
function ct.GetUnitsInCone(otherUnit, angle, distance, mode, onlyCombat, healthPercent)
  if otherUnit == nil then
    return nil
  end

  local ObjectCount = GetObjectCount()
  local Object = nil
  local Units = {}
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and ct.IsFacing(Object, angle) and ct.IsInRange(otherUnit, Object, distance)
    and UnitHealth(Object) > 1 and (healthPercent == nil or ct.PercentHealth(Object) <= healthPercent) then
      if mode == "friendly" and ((not ct.UnitIsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      elseif mode == "hostile" and ct.UnitIsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        table.insert(Units, Object)
      end
    end
  end
  return Units
end

-- returns the percent value of the unit's spellcast progress
function ct.CastedPercent(unit)
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

-- returns the number of units that are below the given health threshold
-- mode : friendly or hostile
-- onlyCombat (optional) : true or false
-- unit (optional) : needed for range
-- range (optional) : the range which shall be scanned for units
function ct.GetUnitCountBelowHealth(healthPercent, mode, onlyCombat, unit, range)
  local Count = 0
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and ct.PercentHealth(Object) < healthPercent
    and ((range == nil and unit == nil) or ct.IsInRange(unit, Object, range)) then
      if mode == "friendly" and ((not ct.UnitIsHostile(Object) and UnitIsPlayer(Object))
      or (UnitInParty(Object) or UnitInRaid(Object)))
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Count = Count + 1
      elseif mode == "hostile" and ct.UnitIsHostile(Object)
      and (onlyCombat == false or onlyCombat == nil or UnitAffectingCombat(Object)) then
        Count = Count + 1
      end
    end
  end
  return Count
end

-- returns the unit objects of the tanks and specifies them as main and off tank, return nil if not found
function ct.FindTanks()


  -- find tanks
  local Tanks = {}
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit)
    and (UnitInParty(Object) or UnitInRaid(Object))
    and (UnitGroupRolesAssigned(Object) == "TANK" or ObjectID(Object) == 72218) then
      table.insert(Tanks, Object)
    end
  end

  -- specify main and off tank
  local MainTank  = nil
  local OffTank   = nil

  for i = 1, getn(Tanks) do
    if ct.IsTankingBoss(Tanks[i]) or getn(Tanks) == 1 then
      MainTank = Tanks[i]
    else
      OffTank = Tanks[i]
    end
  end

  return MainTank, OffTank
end

-- returns true when the given unit is tanking a boss
function ct.IsTankingBoss(unit)
  if unit == nil then
    return nil
  end

  local Target = UnitTarget(unit)
  -- Dungeon Bosses
  for i = 1, getn(ct.DungeonBosses) do
    if ct.GetCreatureID(Target) == ct.DungeonBosses[i] then
      return true
    end
  end
  -- Raid Bosses
  for i = 1, getn(ct.RaidBosses) do
    if ct.GetCreatureID(Target) == ct.RaidBosses[i] then
      return true
    end
  end
  return false
end

-- returns the percent value of the unit's current health
function ct.PercentHealth(unit)
  if unit == nil then
    return nil
  end

  return math.floor((UnitHealth(unit) / UnitHealthMax(unit)) * 100)
end

-- returns ID of the spell that was previously casted
function ct.GetPreviousSpell()
  if ct.SpellHistory ~= nil and getn(ct.SpellHistory) ~= 0 then
    local TableLenght = getn(ct.SpellHistory)
    return ct.SpellHistory[TableLenght].spell
  end
  return nil
end

-- returns the time in ms since the last spell was casted
function ct.GetTimeSinceLastSpell()
  if ct.SpellHistory ~= nil and getn(ct.SpellHistory) ~= 0 then
    local TableLenght = getn(ct.SpellHistory)
    return (GetTime() - ct.SpellHistory[TableLenght].time) * 1000
  end
  return nil
end

-- returns the spell id of the given spell name
function ct.GetSpellID(name)
  return select(7, GetSpellInfo(name))
end

-- given an unit, returns table of all of the unit's auras
function ct.GetUnitAuras(unit)
  Auras = {}
  AuraCount = ct.GetAuraCount(unit)
  for i = 1, AuraCount do
    Auras[i] = select(11, UnitAura(unit, i))
  end
  return Auras
end

-- produces the time to die for the given unit
function ct.ComputeTTD(unit)
end

-- returns the ID of the given unit (must be a creature)
function ct.GetCreatureID(unit)
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
