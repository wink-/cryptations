local Debuff  = LibStub("Debuff")
local Spell = LibStub("Spell")

-- given an unit and a DebuffID, produces true if unit has Debuff
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the Debuff from the player
function Debuff.Has(unit, DebuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local DebuffName = Spell.GetName(DebuffID)
  local HasDebuff, _, _, _, _, _, _, Caster = UnitDebuff(unit, DebuffName)

  if HasDebuff
  and (onlyPlayer ~= true or Caster == "player") then
    return true
  end

  return false
end

-- returns the remaining time of the given Debuff on the given unit
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the Debuff from the player
-- returns 0 if the given unit does not have a Debuff that meets the parameters
function Debuff.RemainingTime(unit, DebuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local DebuffName = Spell.GetName(DebuffID)
  if DebuffName == nil or DebuffName == "" then return 0 end

  local _, _, _, _, _, _, Expires, Caster = UnitDebuff(unit, DebuffName)

  if Expires
  and (onlyPlayer ~= true or Caster == "player") then
    return Expires - GetTime()
  end

  return 0
end

-- returns the stack count of the given Debuff on the given unit
-- onlyPlayer (optional): if this is checked, only returns true if the unit has the Debuff from the player
-- returns 0 if the given unit does not have a Debuff that meets the parameters
function Debuff.Stacks(unit, DebuffID, onlyPlayer)
  if unit == nil then
    return nil
  end

  local DebuffName = Spell.GetName(DebuffID)
  if DebuffName == nil or DebuffName == "" then return 0 end

  local _, _, _, Stacks, _, _, _, Caster = UnitDebuff(unit, DebuffName)

  if Stacks
  and (onlyPlayer ~= true or Caster == "player") then
    return Stacks
  end

  return 0
end

-- returns table containing every unit that has the given Debuff
-- onlyPlayer (optional): if this is checked, only units that got the Debuff from the player will be returned
function Debuff.FindUnitsWith(DebuffID, onlyPlayer)
  local Units = {}

  -- check for enemys
  for Object, _ in pairs(UNIT_TRACKER) do
    if Debuff.Has(Object, DebuffID, onlyPlayer) then
      table.insert(Units, Object)
    end
  end

  -- check for group members
  for i = 1, #GROUP_MEMBERS do
    if Debuff.Has(GROUP_MEMBERS[i], DebuffID, onlyPlayer) then
      table.insert(Units, Object)
    end
  end

  if #Units ~= 0 then
    return Units
  end

  return nil
end
