-- returns true if a given unit is valid to be attacked
function ct.UnitIsHostile(unit)
  if unit ~= nil
  and (UnitIsEnemy(ct.player, unit) or UnitCanAttack(ct.player, unit)) then
    return true
  else
    return false
  end
end

-- several checks to determine whether or not a spell can be casted
-- returns true if all checks pass
-- TODO: automatically figure out required power and power type
function ct.CanCast(spell, unit, powerType, power)
  return select(1, GetSpellCooldown(spell) == 0) and (unit == nil or ct.IsInAttackRange(spell, unit))
  and IsSpellKnown(spell) and ((powerType == nil and power == nil) or UnitPower(ct.player, powerType) >= power)
end

-- produces true if the facing angle between player and unit is smaller or equal to given angle
function ct.IsFacing(unit, angle)
  if unit == nil then
    return false
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
  if not ObjectExists(unit) then
    return nil
  end

  local px, py, pz = ObjectPosition(ct.player)
  local ux, uy, uz = ObjectPosition(unit)

  return TraceLine(px, py, pz + 2, ux, uy, uz + 2, 0x10) == nil
end

-- returns true if distance between player and given unit
-- is lower or equal to given distance
function ct.IsInRange(unit, distance)
  return GetDistanceBetweenObjects(ct.player, unit) <= distance
end

-- same as above but this one considers the boundingboxes and combat reach
function ct.IsInAttackRange(spell, unit)
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
  local AuraIndex = 1
  local AuraCount = 0

  while (select(1, UnitAura(unit, AuraIndex))) do
    AuraIndex = AuraIndex + 1
    AuraCount = AuraCount + 1
  end
  return AuraCount
end

-- returns table containing every unit in ct.units that has the given aura
function ct.FindUnitsWithAura(auraID)
  local UnitsWithAura = {}
  local UnitIndex = 1
  for i = 1, table.getn(ct.units) do
    for j = 1, ct.GetAuraCount(ct.units[i][1]) do
      if ct.units[i][2][j] == auraID then
        UnitsWithAura[UnitIndex] = ct.units[i][1]
        UnitIndex = UnitIndex + 1
      end
    end
  end

  if table.getn(UnitsWithAura) ~= 0 then
    return UnitsWithAura
  else
    return nil
  end
end

-- return the unit with the most health percentage out of the given table
function ct.FindHighestUnit(table)
  local Highest = nil

  if getn(table) == 0 then
    return nil
  end

  for index, value in ipairs(table) do
    local Unit = table[index][1]
    if Highest == nil or ct.HealthPercent(Unit) > ct.HealthPercent(Highest) then
      Highest = Unit
    end
  end
  return Highest
end

-- return the unit with the least health percentage out of the given table
-- ignores dead units
function ct.FindLowestUnit(table)
  local Lowest = nil

  if getn(table) == 0 then
    return nil
  end

  for index, value in ipairs(table) do
    local Unit = table[index][1]
    if Lowest == nil or ct.HealthPercent(Unit) < ct.HealthPercent(Lowest and UnitHealth(Unit) ~= 0) then
      Lowest = Unit
    end
  end
  return Lowest
end

-- return the unit from the given table which is closest to the player
-- ignores dead units
function ct.FindNearestUnit(table)
  local Nearest = nil

  if getn(table) == 0 then
    return nil
  end

  for index, value in ipairs(table) do
    if Nearest == nil
    or GetDistanceBetweenObjects(ct.player, table[index][1]) < GetDistanceBetweenObjects(ct.player, Nearest) then
      Nearest = table[index][1]
    end
  end
  return Nearest
end

-- returns true if player is currently casting a spell
function ct.PlayerIsCasting()
  if select(6, UnitCastingInfo(ct.player)) == nil
  or GetTime() * 1000 >= select(6, UnitCastingInfo(ct.player)) - ct.CastDelay then
    return false
  else
    return true
  end
end

-- returns the number of units from the given table in the given range (to the player)
function ct.GetUnitCountInRadius(table, radius)
  local Count = 0
  for i = 1, getn(table) do
    if ct.IsInRange(table[i][1], radius) then
      Count = Count + 1
    end
  end
  return Count
end

-- returns table containing units from the given table that are within the given radius
function ct.GetUnitsInRadius(table, radius)
  local Units = {}
  for index, value in ipairs(table) do
    Unit = table[index][i]
    if ct.IsInRange(Unit, radius) then
      table.insert(Units, Unit)
    end
  end
  return Units
end

-- returns the percent value of the unit's spellcast progress
function ct.CastedPercent(unit)
  local CastTime = nil
  local PercentCasted = nil

  if select(5, UnitCastingInfo(unit)) ~= nil then
    CastTime = select(6,  UnitCastingInfo(unit)) - select(5,  UnitCastingInfo(unit))
    PercentCasted = math.floor((1 - (select(6,  UnitCastingInfo(unit)) - GetTime() * 1000) / CastTime) * 100)
  end
  return PercentCasted
end

-- returns the number of units from the given table that are below the given health threshold
function ct.GetUnitCountBelowHealth(table, healthPercent)
  local Count = 0
  for index, value in ipairs(table) do
    Unit = table[index][1]
    if (UnitHealth(Unit) / UnitHealthMax(Unit)) * 100 < healthPercent then
      Count = Count + 1
    end
  end
  return Count
end

-- returns the unit objects of the tanks and specifies them as main and off tank, return nil if not found
function ct.FindTanks()
  if GetNumGroupMembers() == 1 then
    return nil
  end

  -- find tanks
  local Tanks = {}

  -- Proving Grounds
  local Table = ct.friends
  if select(8, GetInstanceInfo()) == 1148 then
    Table = ct.npcs
  end

  for index, value in ipairs(Table) do
    local Unit = Table[index][1]
    if (UnitInParty(Unit) or UnitInRaid(Unit))
    and UnitGroupRolesAssigned(Unit) == "TANK" or ObjectID(Unit) == 72218 then
      table.insert(Tanks, Unit)
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
  local Target = UnitTarget(unit)
  if Target ~= nil and (UnitClassification(Target) == "elite"
  or UnitClassification(Target) == "worldboss") then
    return true
  end
  return false
end

-- returns the percent value of the unit's current health
function ct.PercentHealth(unit)
  return math.floor((UnitHealth(unit) / UnitHealthMax(unit)) * 100)
end
