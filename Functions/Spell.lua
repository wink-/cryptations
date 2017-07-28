local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

SPELL_QUEUE = {}
SPELL_HISTORY = {}

SpellUniqueIdentifier     = 0            -- Every spell will have this value (like a primary key in a database)
CurrentUniqueIdentifier   = nil          -- This is the primary key of the spell that is currently being casted
CurrentSpell              = nil          -- SpellID of the spell currently being casted
CastAngle                 =  90           -- Facing angle for casted spells
MeleeAngle                = 180           -- Facing angle for melee spells
ConeAngle                 =  45           -- Facing angle for cone logic
PreCastTime               = 0.2

-- This is used to bypass some silly bugs related to CastSpellByID
-- Same functionality but adds instant casts to the spell history
function Spell.Cast(SpellID, unit)
  local SpellName = Spell.GetName(SpellID)

  if unit ~= nil and ObjectExists(unit) then
    CastSpellByName(SpellName, unit)
  else
    CastSpellByName(SpellName)
  end

  -- Add to spell history if it is an instant cast
  local _, _, _, CastTime = GetSpellInfo(SpellID)
  if CastTime == 0 then
    Spell.AddToHistory(SpellID)
  end
end

-- This casts a ground spell to the given coordinates
function Spell.CastGroundSpell(SpellID, x, y, z)
  if x ~= nil and y ~= nil and z ~= nil then
    Spell.Cast(SpellID)
    ClickPosition(x, y, z)
  end
end

-- returns the string representation of the spellname from the given SpellID
function Spell.GetName(SpellID)
  local Name = GetSpellInfo(SpellID)
  return Name
end

-- returns the spell id of the given spell name
function Spell.GetID(name)
  local _, _, _, _, _, _, ID = GetSpellInfo(name)
  return ID
end

-- several checks to determine whether or not a spell can be casted
-- returns true if all checks pass
-- checkIfKnown (optional) : if true, checks if the spell is known
function Spell.CanCast(spell, unit, powerType, power, checkIfKnown)
  local SpellCooldown = GetSpellCooldown(spell)
  return SpellCooldown == 0 and (unit == nil or Unit.IsInAttackRange(spell, unit))
  and (IsSpellKnown(spell) or checkIfKnown == false)
  and (not Unit.IsMoving(PlayerUnit) or Spell.CanCastWhileMoving(spell))
  and ((powerType == nil and power == nil) or UnitPower(PlayerUnit, powerType) >= power)
end

-- returns true if player can cast while moving (e.g. ice floes)
-- or if given spell can be casted while moving (e.g. instant cast, scorch, ...)
function Spell.CanCastWhileMoving(spell)
  -- check if a spell is instant cast
  local _, _, _, CastTime = GetSpellInfo(spell)
  if CastTime == 0 then
    return true
  else
    return false
  end

  -- check if player is affected by auras that allow casting while moving
  for i, v in ipairs(CastWhileMovingAuras) do
    if Buff.Has(PlayerUnit, CastWhileMovingAuras[i]) then
      return true
    end
  end

  -- check if player is casting a spell that can be casted while moving
  for i, v in ipairs(CastWhileMovingSpells) do
    if spell == CastWhileMovingSpells[i] then
      return true
    end
  end
end

-- returns ID of the spell that was previously casted
function Spell.GetPreviousSpell()
  if SPELL_HISTORY ~= nil and #SPELL_HISTORY ~= 0 then
    local TableLenght = #SPELL_HISTORY
    return SPELL_HISTORY[TableLenght].spell
  end
  return nil
end

-- returns the time in ms since the last spell was casted
function Spell.GetTimeSinceLastSpell()
  if SPELL_HISTORY ~= nil and #SPELL_HISTORY ~= 0 then
    local TableLenght = #SPELL_HISTORY
    return (GetTime() - SPELL_HISTORY[TableLenght].time) * 1000
  end
  return nil
end

-- returns the remaining cooldown of the given spell in seconds
function Spell.GetRemainingCooldown(spell)
  local SpellCooldown = GetSpellCooldown(spell)
  if SpellCooldown == 0 then
    return 0
  end

  local _, Duration = GetSpellCooldown(spell)
  local EndTime = SpellCooldown + Duration

  return EndTime - GetTime()
end

-- Adds the given spell to the spell history and keeps the size at a maximum of 10 entries
function Spell.AddToHistory(spell)
  -- maximum lenght of spell history is 10 entries
  if #SPELL_HISTORY > 10 then
    table.remove(SPELL_HISTORY, 1)
  end

  -- add spell to history like : SPELL; TARGET; TIME
  local Entry = {spell = spell, time = GetTime()}
  table.insert(SPELL_HISTORY, Entry)
end

-- adds an entry to the SpellQueue
-- entry can contain spellID and unit to cast the spell on
function Spell.AddToQueue(spell, unit)
  -- Add every spell from a sequence
  if type(spell) == "table" then
    for i = 1, #spell do
      SpellUniqueIdentifier = SpellUniqueIdentifier + 1
      local QueueEntry = {spell = spell[i], unit = unit, key = SpellUniqueIdentifier}
      table.insert(SPELL_QUEUE, QueueEntry)
    end
  -- Add Single Spell
  else
    SpellUniqueIdentifier = SpellUniqueIdentifier + 1
    local QueueEntry = {spell = spell, unit = unit, key = SpellUniqueIdentifier}
    table.insert(SPELL_QUEUE, QueueEntry)
  end
end

-- removes the given spell from the queue if it is at first position
function Spell.DeQueue(spell)
  -- exit if queue is empty
  if #SPELL_QUEUE == 0 then
    return
  end

  -- find spell in queue and dequeue it
  if SPELL_QUEUE[1].spell == spell then
    table.remove(SPELL_QUEUE, 1)
  end
end

-- This detects the completition of casted spells
-- This is needed because of the way how the rotation chains up spells
-- The rotation tries to cast spells with as little delay as possible
-- and therefore using the "succeeded" event would not be fast enough
function Spell.DetectionHandler()
  -- add spell to the history (no matter if it was on the queue or not)
  if not Unit.IsCasting(PlayerUnit) and CurrentSpell ~= nil then
    Spell.AddToHistory(CurrentSpell)
    CurrentSpell = nil
  end

  -- remove them from the queue
  if not Unit.IsCasting(PlayerUnit) and Unit.CastedPercent(PlayerUnit) ~= nil
  and SPELL_QUEUE[1] ~= nil
  and CurrentUniqueIdentifier == SPELL_QUEUE[1].key then
    Spell.DeQueue(CurrentSpell)
    CurrentSpell = nil
  end
end

-- wrapper for GetSpellCharges
-- only returns the current charge count of the given spell
function Spell.GetCharges(spellID)
  local Charges = GetSpellCharges(spellID)
  return Charges
end

-- returns the remaining time in seconds for the current charge to become active
function Spell.GetRemainingChargeTime(spellID)
  local Charges, MaxCharges, Start, Duration = GetSpellCharges(spellID)
  if Charges >= MaxCharges then return 0 end

  return (Start + Duration) - GetTime()
end
