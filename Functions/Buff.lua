local Buff  = LibStub("Buff")
local Spell = LibStub("Spell")

-- given an unit and a buffID, produces true if unit has Buff
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
function Buff.Has(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local BuffName = Spell.GetName(buffID)
  local HasBuff, _, _, _, _, _, _, Caster = UnitBuff(unit, BuffName)

  if HasBuff
  and (onlyPlayer ~= true or Caster == "player") then
    return true
  end

  return false
end

-- returns the remaining time of the given buff on the given unit
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
-- returns 0 if the given unit does not have a buff that meets the parameters
function Buff.RemainingTime(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local BuffName = Spell.GetName(buffID)
  if BuffName == nil or BuffName == "" then return 0 end

  local _, _, _, _, _, _, Expires, Caster = UnitBuff(unit, BuffName)

  if Expires
  and (onlyPlayer ~= true or Caster == "player") then
    return Expires - GetTime()
  end

  return 0
end

-- returns the stack count of the given buff on the given unit
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the buff from the player
-- returns 0 if the given unit does not have a buff that meets the parameters
function Buff.Stacks(unit, buffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local BuffName = Spell.GetName(buffID)
  if BuffName == nil or BuffName == "" then return 0 end

  local _, _, _, Stacks, _, _, _, Caster = UnitBuff(unit, BuffName)

  if Stacks
  and (onlyPlayer ~= true or Caster == "player") then
    return Stacks
  end

  return 0
end

-- returns table containing every unit that has the given buff
-- onlyPlayer (optional): if this is checked, only units that got the buff from the player will be returned
function Buff.FindUnitsWith(buffID, onlyPlayer)
  local Units = {}

  -- check for enemys
  for Object, _ in pairs(UNIT_TRACKER) do
    if Buff.Has(Object, buffID, onlyPlayer) then
      table.insert(Units, Object)
    end
  end

  -- check for group members
  for i = 1, #GROUP_MEMBERS do
    if Buff.Has(GROUP_MEMBERS[i], buffID, onlyPlayer) then
      table.insert(Units, Object)
    end
  end

  return Units
end
