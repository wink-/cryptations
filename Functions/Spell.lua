local Spell = LibStub:NewLibrary("Spell", 1)

local Unit = LibStub("Unit")
local PreCastTime = 0.2

-- This is used to bypass some silly bugs related to CastSpellByID
-- Same functionality but adds instant casts to the spell history
function Spell.Cast(SpellID, unit)
  local SpellName = Spell.GetSpellName(SpellID)

  if unit ~= nil and ObjectExists(unit) then
    CastSpellByName(SpellName, unit)
  else
    CastSpellByName(SpellName)
  end

  -- Add to spell history if it is a instant cast
  if select(4, GetSpellInfo(SpellID)) == 0 then
    ct.AddSpellToHistory(SpellID)
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
function Spell.GetSpellName(SpellID)
  return select(1, GetSpellInfo(SpellID))
end

-- returns the spell id of the given spell name
function Spell.GetSpellID(name)
  return select(7, GetSpellInfo(name))
end

-- several checks to determine whether or not a spell can be casted
-- returns true if all checks pass
-- checkIfKnown (optional) : if true, checks if the spell is known
function Spell.CanCast(spell, unit, powerType, power, checkIfKnown)
  return select(1, GetSpellCooldown(spell)) == 0 and (unit == nil or Unit.IsInAttackRange(spell, unit))
  and (IsSpellKnown(spell) or checkIfKnown == false)
  and (not Unit.IsMoving(ct.player) or Unit.CanCastWhileMoving(spell))
  and ((powerType == nil and power == nil) or UnitPower(ct.player, powerType) >= power)
end

-- returns true if player can cast while moving (e.g. ice floes)
-- or if given spell can be casted while moving (e.g. instant cast, scorch, ...)
function Spell.CanCastWhileMoving(spell)
  -- check if a spell is instant cast
  if select(4, GetSpellInfo(spell)) == 0 then
    return true
  else
    return false
  end

  -- check if player is affected by auras that allow casting while moving
  for i, v in ipairs(ct.CastWhileMovingAuras) do
    if Buff.Has(ct.player, ct.CastWhileMovingAuras[i]) then
      return true
    end
  end

  -- check if player is casting a spell that can be casted while moving
  for i, v in ipairs(ct.CastWhileMovingSpells) do
    if spell == ct.CastWhileMovingSpells[i] then
      return true
    end
  end
end

-- returns ID of the spell that was previously casted
function Spell.GetPreviousSpell()
  if ct.SpellHistory ~= nil and getn(ct.SpellHistory) ~= 0 then
    local TableLenght = getn(ct.SpellHistory)
    return ct.SpellHistory[TableLenght].spell
  end
  return nil
end

-- returns the time in ms since the last spell was casted
function Spell.GetTimeSinceLastSpell()
  if ct.SpellHistory ~= nil and getn(ct.SpellHistory) ~= 0 then
    local TableLenght = getn(ct.SpellHistory)
    return (GetTime() - ct.SpellHistory[TableLenght].time) * 1000
  end
  return nil
end

-- returns the remaining cooldown of the given spell in seconds
function Spell.GetRemainingCooldown(spell)
  if select(1, GetSpellCooldown(spell)) == 0 then
    return 0
  end

  local Start = select(1, GetSpellCooldown(spell))
  local Duration = select(2, GetSpellCooldown(spell))
  local EndTime = Start + Duration

  return EndTime - GetTime()
end
