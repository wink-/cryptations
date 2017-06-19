ct.friends = {}     -- contains all friendly players
ct.npcs = {}        -- contains all friendly non - players
ct.enemys = {}      -- contains all enemy units (npc and player)

local Distance = 100

-- TODO: rework the unit engine so that it is not called every tick but every second or so

-- fills the units tables with appropriate units and their applied auras
function ct.GetUnitTables()
  local ObjectCount     =  GetObjectCount()
  local FriendIndex     =  0
  local NpcIndex        =  0
  local EnemyIndex      =  0
  local AlreadyInTable  =  false
  -- for every object, check if its an unit
  -- if so, check if it exists and if so, add it to the table
  for i = 1, ObjectCount do
    Unit = GetObjectWithIndex(i)
    if ObjectExists(Unit) and ObjectIsType(Unit, ObjectTypes.Unit)
    and UnitHealth(Unit) > 1 -- exclude critters and dead units
    and ct.IsInLOS(Unit) and ct.IsInRange(Unit, Distance) then

      -- distinguish between friend, enemy and npc
      if ct.UnitIsHostile(Unit) then
        -- ENEMYS --
        -- check if not already in table
        for index, value in ipairs(ct.enemys) do
          if ct.enemys[index][1] == Unit then
            AlreadyInTable = true
            break
          end
        end

        if not AlreadyInTable then
          -- add all enemy units to the enemy table
          ct.enemys[EnemyIndex] = {}
          ct.enemys[EnemyIndex][1] = Unit

          -- add the units auras to the table
          ct.enemys[EnemyIndex][2] = ct.GetUnitAuras(Unit)

          EnemyIndex = EnemyIndex + 1
        end
        AlreadyInTable = false
      elseif not ct.UnitIsHostile(Unit) and UnitIsPlayer(Unit)
      or (UnitInParty(Unit) or UnitInRaid(Unit)) then
        -- FRIENDLY PLAYERS --
        -- check if not already in table
        for index, value in ipairs(ct.friends) do
          if ct.friends[index][1] == Unit then
            AlreadyInTable = true
            break
          end
        end

        if not AlreadyInTable then
          -- add all friendly player units to the enemy table
          ct.friends[FriendIndex] = {}
          ct.friends[FriendIndex][1] = Unit

          -- add the units auras to the table
          ct.friends[FriendIndex][2] = ct.GetUnitAuras(Unit)

          FriendIndex = FriendIndex + 1
        end
        AlreadyInTable = false
      else
        -- NPCS --
        -- check if not already in table
        for index, value in ipairs(ct.npcs) do
          if ct.npcs[index][1] == Unit then
            AlreadyInTable = true
            break
          end
        end

        if not AlreadyInTable then
          -- add all friendly player units to the enemy table
          ct.npcs[NpcIndex] = {}
          ct.npcs[NpcIndex][1] = Unit

          -- add the units auras to the table
          ct.npcs[NpcIndex][2] = ct.GetUnitAuras(Unit)

          NpcIndex = NpcIndex + 1
        end
        AlreadyInTable = false
      end
    end
  end
end

-- updates all tables and their auras and deletes invalid units
function ct.UpdateTables()
  -- update ct.friends
  for index, value in ipairs(ct.friends) do
    Unit = ct.friends[index][1]
      if not ObjectExists(Unit) or UnitHealth(Unit) <= 1
      or not ct.IsInLOS(Unit) or not ct.IsInRange(Unit, Distance) then
        -- delete invalid unit
        table.remove(ct.friends, index)
      else
        -- update unit auras
        ct.friends[index][2] = ct.GetUnitAuras(Unit)
      end
  end

  -- update ct.npcs
  for index, value in ipairs(ct.npcs) do
    Unit = ct.npcs[index][1]
      if not ObjectExists(Unit) or UnitHealth(Unit) <= 1
      or not ct.IsInLOS(Unit) or not ct.IsInRange(Unit, Distance) then
        -- delete invalid unit
        table.remove(ct.npcs, index)
      else
        -- update unit auras
        ct.npcs[index][2] = ct.GetUnitAuras(Unit)
      end
  end

  -- update ct.enemys
  for index, value in ipairs(ct.enemys) do
    Unit = ct.enemys[index][1]
      if not ObjectExists(Unit) or UnitHealth(Unit) <= 1
      or not ct.IsInLOS(Unit) or not ct.IsInRange(Unit, Distance) then
        -- delete invalid unit
        table.remove(ct.enemys, index)
      else
        -- update unit auras
        ct.enemys[index][2] = ct.GetUnitAuras(Unit)
      end
  end
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
